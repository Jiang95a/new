-- ============================================================================
-- 演示数据：给后端同学一个「打开就能看到东西」的起点
--
--   mysql -u campus_app -p campus_diy < docs/sql/002_seed.sql
--
-- 用固定 UUID，所以可以重复执行（ON DUPLICATE KEY UPDATE）。
-- 这些数据只用于开发联调，不要带到生产。
-- ============================================================================

SET NAMES utf8mb4;

-- 演示用户（password_hash 只是占位，不是真密码；后端登录逻辑接上后请替换）
INSERT INTO users (id, email, password_hash, display_name, status)
VALUES (
  '00000000-0000-4000-8000-000000000001',
  'demo@example.com',
  '$2b$12$placeholderplaceholderplaceholderplaceholderplaceholder',
  '演示同学',
  'active'
)
ON DUPLICATE KEY UPDATE id = id;

-- 演示模板：社团招新（document 结构与前端的 DocPlan 对齐）
INSERT INTO templates (id, code, name, category, description, document)
VALUES (
  '00000000-0000-4000-8000-000000000101',
  'recruitment-club',
  '社团招新',
  'recruitment',
  '首页 + 社团介绍 + 报名表单 + 报名成功，适合社团招新场景',
  JSON_OBJECT(
    'intent', '社团招新',
    'reason', '模板：招新场景的标准四页结构',
    'theme', JSON_OBJECT(
      'primary', '#1F2937',
      'accent', '#F59E0B',
      'bg', '#FFFFFF',
      'text', '#111827',
      'radius', 12,
      'fontScale', 1,
      'spacing', 1,
      'buttonStyle', 'solid',
      'font', 'sans'
    ),
    'title', '摄影社招新',
    'pages', JSON_ARRAY(
      JSON_OBJECT('name', '首页', 'role', 'home', 'blocks',
        JSON_ARRAY(
          JSON_OBJECT('type', 'nav', 'props', JSON_OBJECT('title', '摄影社')),
          JSON_OBJECT('type', 'banner', 'props', JSON_OBJECT('title', '光影之间', 'subtitle', '2026 秋季招新')),
          JSON_OBJECT('type', 'infoCard', 'props', JSON_OBJECT('title', '活动信息')),
          JSON_OBJECT('type', 'button', 'props', JSON_OBJECT('text', '立即报名'))
        )),
      JSON_OBJECT('name', '社团介绍', 'role', 'content', 'blocks',
        JSON_ARRAY(
          JSON_OBJECT('type', 'heading', 'props', JSON_OBJECT('text', '我们是谁')),
          JSON_OBJECT('type', 'text', 'props', JSON_OBJECT('text', '摄影社成立于 2015 年，每周组织外拍。'))
        )),
      JSON_OBJECT('name', '报名表单', 'role', 'form', 'blocks',
        JSON_ARRAY(
          JSON_OBJECT('type', 'form', 'props', JSON_OBJECT('submitText', '提交报名'))
        )),
      JSON_OBJECT('name', '报名成功', 'role', 'success', 'blocks',
        JSON_ARRAY(
          JSON_OBJECT('type', 'heading', 'props', JSON_OBJECT('text', '报名成功')),
          JSON_OBJECT('type', 'qrcode', 'props', JSON_OBJECT('caption', '扫码加群'))
        ))
    )
  )
)
ON DUPLICATE KEY UPDATE id = id;

-- 演示项目（草稿 + 已发布 slug）
INSERT INTO projects (
  id, owner_id, template_id, title, description, status,
  draft_document, draft_revision, public_slug, publish_settings
)
VALUES (
  '00000000-0000-4000-8000-000000000201',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000101',
  '摄影社招新（演示）',
  '用来联调的演示项目：一句需求生成、编辑、发布、提交都能在这上面跑',
  'published',
  JSON_OBJECT('title', '摄影社招新（演示）', 'pages', JSON_ARRAY()),
  1,
  'photo-club-2026',
  JSON_OBJECT('allowIndex', true)
)
ON DUPLICATE KEY UPDATE id = id;

-- 验证：
--   SELECT id, email, display_name FROM users;
--   SELECT code, name, category FROM templates;
--   SELECT title, status, public_slug FROM projects;
