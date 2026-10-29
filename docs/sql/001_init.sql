-- 校园轻活动 AI DIY 工坊
-- PostgreSQL 16 初始化结构

BEGIN;

CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email CITEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  display_name VARCHAR(80) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'disabled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE auth_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash CHAR(64) NOT NULL UNIQUE,
  user_agent VARCHAR(512),
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(60) NOT NULL UNIQUE,
  name VARCHAR(120) NOT NULL,
  category VARCHAR(40) NOT NULL
    CHECK (category IN ('recruitment', 'registration', 'vote', 'checkin')),
  description TEXT,
  cover_url TEXT,
  document JSONB NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (jsonb_typeof(document) = 'object')
);

CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  template_id UUID REFERENCES templates(id) ON DELETE SET NULL,
  title VARCHAR(160) NOT NULL,
  description TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'published', 'unpublished', 'archived')),
  draft_document JSONB NOT NULL DEFAULT '{}'::jsonb,
  draft_revision BIGINT NOT NULL DEFAULT 0 CHECK (draft_revision >= 0),
  public_slug VARCHAR(80),
  published_version_id UUID,
  publish_settings JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  CHECK (jsonb_typeof(draft_document) = 'object'),
  CHECK (jsonb_typeof(publish_settings) = 'object'),
  CHECK (public_slug IS NULL OR public_slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$')
);

CREATE TABLE page_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  version_no INTEGER NOT NULL CHECK (version_no > 0),
  document JSONB NOT NULL,
  source VARCHAR(30) NOT NULL DEFAULT 'manual'
    CHECK (source IN ('manual', 'ai', 'template')),
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (project_id, version_no),
  CHECK (jsonb_typeof(document) = 'object')
);

ALTER TABLE projects
  ADD CONSTRAINT projects_published_version_fk
  FOREIGN KEY (published_version_id)
  REFERENCES page_versions(id)
  ON DELETE SET NULL;

CREATE TABLE project_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  object_key TEXT NOT NULL UNIQUE,
  mime_type VARCHAR(100) NOT NULL,
  size_bytes BIGINT NOT NULL CHECK (size_bytes > 0),
  sha256 CHAR(64) NOT NULL,
  width INTEGER CHECK (width IS NULL OR width > 0),
  height INTEGER CHECK (height IS NULL OR height > 0),
  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'ready', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE form_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  version_id UUID NOT NULL REFERENCES page_versions(id) ON DELETE RESTRICT,
  page_id VARCHAR(80) NOT NULL,
  form_component_id VARCHAR(80) NOT NULL,
  answers JSONB NOT NULL,
  idempotency_key UUID NOT NULL,
  submitter_hash TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'valid'
    CHECK (status IN ('valid', 'invalid')),
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (project_id, idempotency_key),
  CHECK (jsonb_typeof(answers) = 'object')
);

CREATE TABLE ai_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  kind VARCHAR(40) NOT NULL
    CHECK (kind IN (
      'generate_from_prompt',
      'generate_from_poster',
      'component_suggestions',
      'quality_check'
    )),
  status VARCHAR(20) NOT NULL DEFAULT 'queued'
    CHECK (status IN ('queued', 'running', 'succeeded', 'failed', 'cancelled')),
  client_request_id VARCHAR(100),
  input_payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  result_payload JSONB,
  model_provider VARCHAR(60),
  model_name VARCHAR(100),
  error_code VARCHAR(80),
  error_message TEXT,
  started_at TIMESTAMPTZ,
  finished_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (jsonb_typeof(input_payload) = 'object'),
  CHECK (result_payload IS NULL OR jsonb_typeof(result_payload) = 'object'),
  UNIQUE (user_id, client_request_id)
);

CREATE TABLE ai_proposals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES ai_jobs(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  base_version_id UUID REFERENCES page_versions(id) ON DELETE SET NULL,
  base_revision BIGINT NOT NULL CHECK (base_revision >= 0),
  target JSONB NOT NULL DEFAULT '{}'::jsonb,
  summary TEXT NOT NULL,
  candidate_document JSONB,
  operations JSONB NOT NULL DEFAULT '[]'::jsonb,
  rationale JSONB NOT NULL DEFAULT '[]'::jsonb,
  risk VARCHAR(20) NOT NULL DEFAULT 'low'
    CHECK (risk IN ('low', 'medium', 'high')),
  status VARCHAR(20) NOT NULL DEFAULT 'proposed'
    CHECK (status IN ('proposed', 'applied', 'rejected', 'stale')),
  applied_revision BIGINT CHECK (applied_revision IS NULL OR applied_revision >= 0),
  applied_by UUID REFERENCES users(id) ON DELETE SET NULL,
  applied_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (jsonb_typeof(target) = 'object'),
  CHECK (candidate_document IS NULL OR jsonb_typeof(candidate_document) = 'object'),
  CHECK (jsonb_typeof(operations) = 'array'),
  CHECK (jsonb_typeof(rationale) = 'array')
);

CREATE TABLE activity_events (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  event_type VARCHAR(40) NOT NULL
    CHECK (event_type IN (
      'public_page_view',
      'form_started',
      'form_submitted',
      'submission_succeeded',
      'submission_rejected'
    )),
  page_id VARCHAR(80),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (jsonb_typeof(metadata) = 'object')
);

CREATE TABLE export_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  requested_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(20) NOT NULL DEFAULT 'queued'
    CHECK (status IN ('queued', 'running', 'succeeded', 'failed', 'expired')),
  filters JSONB NOT NULL DEFAULT '{}'::jsonb,
  object_key TEXT,
  error_message TEXT,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ,
  CHECK (jsonb_typeof(filters) = 'object')
);

CREATE INDEX idx_projects_owner_updated
  ON projects (owner_id, updated_at DESC)
  WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX uq_projects_public_slug
  ON projects (public_slug)
  WHERE public_slug IS NOT NULL;

CREATE INDEX idx_page_versions_project_version
  ON page_versions (project_id, version_no DESC);

CREATE INDEX idx_assets_owner_created
  ON project_assets (owner_id, created_at DESC);

CREATE INDEX idx_assets_project
  ON project_assets (project_id, created_at DESC)
  WHERE project_id IS NOT NULL;

CREATE INDEX idx_submissions_project_submitted
  ON form_submissions (project_id, submitted_at DESC);

CREATE INDEX idx_submissions_project_status
  ON form_submissions (project_id, status);

CREATE INDEX idx_submissions_version
  ON form_submissions (version_id);

CREATE INDEX idx_ai_jobs_user_created
  ON ai_jobs (user_id, created_at DESC);

CREATE INDEX idx_ai_jobs_project_created
  ON ai_jobs (project_id, created_at DESC);

CREATE INDEX idx_ai_proposals_project_status_created
  ON ai_proposals (project_id, status, created_at DESC);

CREATE INDEX idx_activity_events_project_type_time
  ON activity_events (project_id, event_type, occurred_at DESC);

CREATE INDEX idx_export_jobs_project_created
  ON export_jobs (project_id, created_at DESC);

CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_templates_updated_at
BEFORE UPDATE ON templates
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_projects_updated_at
BEFORE UPDATE ON projects
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMIT;
