-- 校园轻活动 AI DIY 工坊 —— MySQL 初始化结构
-- 对应 PRD 第 8 节的数据模型；接口契约见 ../api/openapi.yaml
--
-- ============================================================================
-- 版本要求：MySQL >= 8.0.16
--   8.0.13+ 才支持 JSON / UUID 的表达式默认值 DEFAULT (UUID())
--   8.0.16+ 才真正强制执行 CHECK 约束（5.7 会静默忽略）
--
-- 与 PostgreSQL 版的差异（原版归档在 legacy/001_init_postgres.sql）：
--   1. UUID 主键：CHAR(36) NOT NULL DEFAULT (UUID())     ← PG 用原生 uuid 类型
--   2. JSONB → JSON；jsonb_typeof(x)='object' → JSON_TYPE(x)='OBJECT'
--   3. CITEXT（大小写不敏感邮箱）→ VARCHAR(190) + utf8mb4_unicode_ci 排序规则
--   4. TIMESTAMPTZ → DATETIME（不带时区）。**全库统一按 UTC 或统一按 +08:00，不能混**
--   5. 部分索引（带 WHERE 的索引）MySQL 不支持 → 改成普通索引；
--      public_slug 的唯一性靠「MySQL 唯一索引允许多个 NULL」等价实现
--   6. 三个 updated_at 触发器删除 → 改用 ON UPDATE CURRENT_TIMESTAMP
--   7. projects.published_version_id 不加外键（会与 page_versions 形成循环依赖），
--      改为普通列 + 索引，由应用层保证一致
--   8. 所有索引写进建表语句，脚本可重复执行（IF NOT EXISTS + 内联索引）
--
-- 字符集必须 utf8mb4：MySQL 的 utf8 只有 3 字节，存不下表情符和生僻字。
-- ============================================================================

SET NAMES utf8mb4;

-- ---------------------------------------------------------------- 用户
CREATE TABLE IF NOT EXISTS users (
  id            CHAR(36)     NOT NULL DEFAULT (UUID()),
  email         VARCHAR(190) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  display_name  VARCHAR(80)  NOT NULL,
  status        VARCHAR(20)  NOT NULL DEFAULT 'active',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  CONSTRAINT ck_users_status CHECK (status IN ('active', 'disabled'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------- 登录会话
CREATE TABLE IF NOT EXISTS auth_sessions (
  id         CHAR(36)     NOT NULL DEFAULT (UUID()),
  user_id    CHAR(36)     NOT NULL,
  token_hash CHAR(64)     NOT NULL,
  user_agent VARCHAR(512) NULL,
  expires_at DATETIME     NOT NULL,
  revoked_at DATETIME     NULL,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sessions_token (token_hash),
  KEY idx_sessions_user_expires (user_id, expires_at),
  CONSTRAINT fk_sessions_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------- 模板
CREATE TABLE IF NOT EXISTS templates (
  id          CHAR(36)     NOT NULL DEFAULT (UUID()),
  code        VARCHAR(60)  NOT NULL,
  name        VARCHAR(120) NOT NULL,
  category    VARCHAR(40)  NOT NULL,
  description TEXT         NULL,
  cover_url   TEXT         NULL,
  document    JSON         NOT NULL,
  is_active   TINYINT(1)   NOT NULL DEFAULT 1,
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_templates_code (code),
  KEY idx_templates_category (category, is_active),
  CONSTRAINT ck_templates_category CHECK (category IN ('recruitment', 'registration', 'vote', 'checkin')),
  CONSTRAINT ck_templates_doc CHECK (JSON_TYPE(document) = 'OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------- 活动项目
CREATE TABLE IF NOT EXISTS projects (
  id                   CHAR(36)     NOT NULL DEFAULT (UUID()),
  owner_id             CHAR(36)     NOT NULL,
  template_id          CHAR(36)     NULL,
  title                VARCHAR(160) NOT NULL,
  description          TEXT         NULL,
  status               VARCHAR(20)  NOT NULL DEFAULT 'draft',
  draft_document       JSON         NOT NULL DEFAULT (JSON_OBJECT()),
  draft_revision       BIGINT       NOT NULL DEFAULT 0,
  public_slug          VARCHAR(80)  NULL,
  published_version_id CHAR(36)     NULL,
  publish_settings     JSON         NOT NULL DEFAULT (JSON_OBJECT()),
  created_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at           DATETIME     NULL,
  PRIMARY KEY (id),
  -- 唯一索引允许多个 NULL，等价于 PG 的「WHERE public_slug IS NOT NULL」部分唯一索引
  UNIQUE KEY uq_projects_public_slug (public_slug),
  KEY idx_projects_owner_updated (owner_id, updated_at),
  KEY idx_projects_template (template_id),
  KEY idx_projects_published_version (published_version_id),
  CONSTRAINT fk_projects_owner FOREIGN KEY (owner_id)
    REFERENCES users (id) ON DELETE RESTRICT,
  CONSTRAINT fk_projects_template FOREIGN KEY (template_id)
    REFERENCES templates (id) ON DELETE SET NULL,
  CONSTRAINT ck_projects_status CHECK (status IN ('draft', 'published', 'unpublished', 'archived')),
  CONSTRAINT ck_projects_revision CHECK (draft_revision >= 0),
  CONSTRAINT ck_projects_draft_doc CHECK (JSON_TYPE(draft_document) = 'OBJECT'),
  CONSTRAINT ck_projects_publish_settings CHECK (JSON_TYPE(publish_settings) = 'OBJECT'),
  CONSTRAINT ck_projects_slug CHECK (
    public_slug IS NULL OR public_slug REGEXP '^[a-z0-9]+(-[a-z0-9]+)*$'
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------- 页面版本
CREATE TABLE IF NOT EXISTS page_versions (
  id          CHAR(36)    NOT NULL DEFAULT (UUID()),
  project_id  CHAR(36)    NOT NULL,
  version_no  INT         NOT NULL,
  document    JSON        NOT NULL,
  source      VARCHAR(30) NOT NULL DEFAULT 'manual',
  created_by  CHAR(36)    NULL,
  created_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_page_versions_project_no (project_id, version_no),
  KEY idx_page_versions_created_by (created_by),
  CONSTRAINT fk_page_versions_project FOREIGN KEY (project_id)
    REFERENCES projects (id) ON DELETE CASCADE,
  CONSTRAINT fk_page_versions_user FOREIGN KEY (created_by)
    REFERENCES users (id) ON DELETE SET NULL,
  CONSTRAINT ck_page_versions_no CHECK (version_no > 0),
  CONSTRAINT ck_page_versions_source CHECK (source IN ('manual', 'ai', 'template')),
  CONSTRAINT ck_page_versions_doc CHECK (JSON_TYPE(document) = 'OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------- 素材（OSS 对象）
CREATE TABLE IF NOT EXISTS project_assets (
  id          CHAR(36)     NOT NULL DEFAULT (UUID()),
  owner_id    CHAR(36)     NOT NULL,
  project_id  CHAR(36)     NULL,
  object_key  TEXT         NOT NULL,
  mime_type   VARCHAR(100) NOT NULL,
  size_bytes  BIGINT       NOT NULL,
  sha256      CHAR(64)     NOT NULL,
  width       INT          NULL,
  height      INT          NULL,
  status      VARCHAR(20)  NOT NULL DEFAULT 'pending',
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  -- TEXT 列不能直接建唯一索引（需要前缀长度），这里用前缀 191
  UNIQUE KEY uq_assets_object_key (object_key(191)),
  KEY idx_assets_owner_created (owner_id, created_at),
  KEY idx_assets_project (project_id, created_at),
  CONSTRAINT fk_assets_owner FOREIGN KEY (owner_id)
    REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_assets_project FOREIGN KEY (project_id)
    REFERENCES projects (id) ON DELETE SET NULL,
  CONSTRAINT ck_assets_size CHECK (size_bytes > 0),
  CONSTRAINT ck_assets_width CHECK (width IS NULL OR width > 0),
  CONSTRAINT ck_assets_height CHECK (height IS NULL OR height > 0),
  CONSTRAINT ck_assets_status CHECK (status IN ('pending', 'ready', 'rejected'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------- 表单提交
CREATE TABLE IF NOT EXISTS form_submissions (
  id                CHAR(36)    NOT NULL DEFAULT (UUID()),
  project_id        CHAR(36)    NOT NULL,
  version_id        CHAR(36)    NOT NULL,
  page_id           VARCHAR(80) NOT NULL,
  form_component_id VARCHAR(80) NOT NULL,
  answers           JSON        NOT NULL,
  idempotency_key   CHAR(36)    NOT NULL,
  submitter_hash    TEXT        NULL,
  status            VARCHAR(20) NOT NULL DEFAULT 'valid',
  submitted_at      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_submissions_project_idem (project_id, idempotency_key),
  KEY idx_submissions_project_submitted (project_id, submitted_at),
  KEY idx_submissions_project_status (project_id, status),
  KEY idx_submissions_version (version_id),
  CONSTRAINT fk_submissions_project FOREIGN KEY (project_id)
    REFERENCES projects (id) ON DELETE CASCADE,
  CONSTRAINT fk_submissions_version FOREIGN KEY (version_id)
    REFERENCES page_versions (id) ON DELETE RESTRICT,
  CONSTRAINT ck_submissions_status CHECK (status IN ('valid', 'invalid')),
  CONSTRAINT ck_submissions_answers CHECK (JSON_TYPE(answers) = 'OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------- AI 任务
CREATE TABLE IF NOT EXISTS ai_jobs (
  id                CHAR(36)     NOT NULL DEFAULT (UUID()),
  project_id        CHAR(36)     NOT NULL,
  user_id           CHAR(36)     NOT NULL,
  kind              VARCHAR(40)  NOT NULL,
  status            VARCHAR(20)  NOT NULL DEFAULT 'queued',
  client_request_id VARCHAR(100) NULL,
  input_payload     JSON         NOT NULL DEFAULT (JSON_OBJECT()),
  result_payload    JSON         NULL,
  model_provider    VARCHAR(60)  NULL,
  model_name        VARCHAR(100) NULL,
  error_code        VARCHAR(80)  NULL,
  error_message     TEXT         NULL,
  started_at        DATETIME     NULL,
  finished_at       DATETIME     NULL,
  created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ai_jobs_user_client (user_id, client_request_id),
  KEY idx_ai_jobs_user_created (user_id, created_at),
  KEY idx_ai_jobs_project_created (project_id, created_at),
  CONSTRAINT fk_ai_jobs_project FOREIGN KEY (project_id)
    REFERENCES projects (id) ON DELETE CASCADE,
  CONSTRAINT fk_ai_jobs_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT ck_ai_jobs_kind CHECK (kind IN (
    'generate_from_prompt', 'generate_from_poster', 'component_suggestions', 'quality_check'
  )),
  CONSTRAINT ck_ai_jobs_status CHECK (status IN ('queued', 'running', 'succeeded', 'failed', 'cancelled')),
  CONSTRAINT ck_ai_jobs_input CHECK (JSON_TYPE(input_payload) = 'OBJECT'),
  CONSTRAINT ck_ai_jobs_result CHECK (result_payload IS NULL OR JSON_TYPE(result_payload) = 'OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------- AI 修改建议
CREATE TABLE IF NOT EXISTS ai_proposals (
  id                 CHAR(36)    NOT NULL DEFAULT (UUID()),
  job_id             CHAR(36)    NOT NULL,
  project_id         CHAR(36)    NOT NULL,
  base_version_id    CHAR(36)    NULL,
  base_revision      BIGINT      NOT NULL,
  target             JSON        NOT NULL DEFAULT (JSON_OBJECT()),
  summary            TEXT        NOT NULL,
  candidate_document JSON        NULL,
  operations         JSON        NOT NULL DEFAULT (JSON_ARRAY()),
  rationale          JSON        NOT NULL DEFAULT (JSON_ARRAY()),
  risk               VARCHAR(20) NOT NULL DEFAULT 'low',
  status             VARCHAR(20) NOT NULL DEFAULT 'proposed',
  applied_revision   BIGINT      NULL,
  applied_by         CHAR(36)    NULL,
  applied_at         DATETIME    NULL,
  created_at         DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_ai_proposals_project_status_created (project_id, status, created_at),
  KEY idx_ai_proposals_job (job_id),
  KEY idx_ai_proposals_base_version (base_version_id),
  KEY idx_ai_proposals_applied_by (applied_by),
  CONSTRAINT fk_ai_proposals_job FOREIGN KEY (job_id)
    REFERENCES ai_jobs (id) ON DELETE CASCADE,
  CONSTRAINT fk_ai_proposals_project FOREIGN KEY (project_id)
    REFERENCES projects (id) ON DELETE CASCADE,
  CONSTRAINT fk_ai_proposals_base_version FOREIGN KEY (base_version_id)
    REFERENCES page_versions (id) ON DELETE SET NULL,
  CONSTRAINT fk_ai_proposals_applied_by FOREIGN KEY (applied_by)
    REFERENCES users (id) ON DELETE SET NULL,
  CONSTRAINT ck_ai_proposals_base_revision CHECK (base_revision >= 0),
  CONSTRAINT ck_ai_proposals_applied_revision CHECK (applied_revision IS NULL OR applied_revision >= 0),
  CONSTRAINT ck_ai_proposals_risk CHECK (risk IN ('low', 'medium', 'high')),
  CONSTRAINT ck_ai_proposals_status CHECK (status IN ('proposed', 'applied', 'rejected', 'stale')),
  CONSTRAINT ck_ai_proposals_target CHECK (JSON_TYPE(target) = 'OBJECT'),
  CONSTRAINT ck_ai_proposals_candidate CHECK (candidate_document IS NULL OR JSON_TYPE(candidate_document) = 'OBJECT'),
  CONSTRAINT ck_ai_proposals_operations CHECK (JSON_TYPE(operations) = 'ARRAY'),
  CONSTRAINT ck_ai_proposals_rationale CHECK (JSON_TYPE(rationale) = 'ARRAY')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------- 行为事件
CREATE TABLE IF NOT EXISTS activity_events (
  id          BIGINT      NOT NULL AUTO_INCREMENT,
  project_id  CHAR(36)    NOT NULL,
  event_type  VARCHAR(40) NOT NULL,
  page_id     VARCHAR(80) NULL,
  metadata    JSON        NOT NULL DEFAULT (JSON_OBJECT()),
  occurred_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_events_project_type_time (project_id, event_type, occurred_at),
  CONSTRAINT fk_events_project FOREIGN KEY (project_id)
    REFERENCES projects (id) ON DELETE CASCADE,
  CONSTRAINT ck_events_type CHECK (event_type IN (
    'public_page_view', 'form_started', 'form_submitted', 'submission_succeeded', 'submission_rejected'
  )),
  CONSTRAINT ck_events_metadata CHECK (JSON_TYPE(metadata) = 'OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------- 导出任务
CREATE TABLE IF NOT EXISTS export_jobs (
  id            CHAR(36)    NOT NULL DEFAULT (UUID()),
  project_id    CHAR(36)    NOT NULL,
  requested_by  CHAR(36)    NOT NULL,
  status        VARCHAR(20) NOT NULL DEFAULT 'queued',
  filters       JSON        NOT NULL DEFAULT (JSON_OBJECT()),
  object_key    TEXT        NULL,
  error_message TEXT        NULL,
  expires_at    DATETIME    NULL,
  created_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  finished_at   DATETIME    NULL,
  PRIMARY KEY (id),
  KEY idx_export_jobs_project_created (project_id, created_at),
  KEY idx_export_jobs_requested_by (requested_by),
  CONSTRAINT fk_export_jobs_project FOREIGN KEY (project_id)
    REFERENCES projects (id) ON DELETE CASCADE,
  CONSTRAINT fk_export_jobs_user FOREIGN KEY (requested_by)
    REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT ck_export_jobs_status CHECK (status IN ('queued', 'running', 'succeeded', 'failed', 'expired')),
  CONSTRAINT ck_export_jobs_filters CHECK (JSON_TYPE(filters) = 'OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 跑完自查：
--   1) 应该看到 11 张表
--        SHOW TABLES;
--   2) 每张表的 Collation 必须带 utf8mb4
--        SELECT TABLE_NAME, TABLE_COLLATION FROM information_schema.TABLES
--         WHERE TABLE_SCHEMA = DATABASE();
--   3) 约束是否生效（MySQL 8.0.16+ 才有值）
--        SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
--         WHERE TABLE_SCHEMA = DATABASE() AND CONSTRAINT_TYPE = 'CHECK';
-- ============================================================================
