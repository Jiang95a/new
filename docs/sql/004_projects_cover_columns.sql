-- ============================================================================
-- 004_projects_cover_columns.sql —— 补 projects 的「封面四件套」
--
-- 背景：commit 4f41332「补全封面字段」只改了 Java（ProjectEntity / ProjectMapper），
--       没同步改 001_init.sql。结果代码里 SELECT activity_type, cover_tone,
--       cover_code, cover_title 全部 Unknown column，项目列表一调就 500。
--
-- 001_init.sql 已经同步补上这四列（新环境不需要再跑本文件）；
-- 这个脚本是给「库已经建好、不想重建」的环境用的，幂等，可重复执行。
--
-- 执行：
--   mysql -u root campus_diy -e "source docs/sql/004_projects_cover_columns.sql"
-- ============================================================================

SET NAMES utf8mb4;

-- MySQL 8.0 的 ADD COLUMN 不支持 IF NOT EXISTS，只能先查 information_schema 再动态执行。
-- 每列一个块，缺哪列补哪列。

SET @ddl := (SELECT IF(COUNT(*) = 0,
    'ALTER TABLE projects ADD COLUMN activity_type VARCHAR(40) NOT NULL DEFAULT ''校园活动'' AFTER description',
    'DO 0')
  FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'projects' AND column_name = 'activity_type');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @ddl := (SELECT IF(COUNT(*) = 0,
    'ALTER TABLE projects ADD COLUMN cover_tone VARCHAR(32) NOT NULL DEFAULT ''photo'' AFTER activity_type',
    'DO 0')
  FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'projects' AND column_name = 'cover_tone');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @ddl := (SELECT IF(COUNT(*) = 0,
    'ALTER TABLE projects ADD COLUMN cover_code VARCHAR(32) NOT NULL DEFAULT ''ACTIVITY'' AFTER cover_tone',
    'DO 0')
  FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'projects' AND column_name = 'cover_code');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @ddl := (SELECT IF(COUNT(*) = 0,
    'ALTER TABLE projects ADD COLUMN cover_title VARCHAR(160) NOT NULL DEFAULT '''' AFTER cover_code',
    'DO 0')
  FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'projects' AND column_name = 'cover_title');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 列表按活动类型筛选会走这个索引（ProjectMapper 里有 activity_type = #{activityType}）
SET @ddl := (SELECT IF(COUNT(*) = 0,
    'CREATE INDEX idx_projects_activity_type ON projects (activity_type)',
    'DO 0')
  FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'projects' AND index_name = 'idx_projects_activity_type');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 演示项目的封面（否则项目卡片上是空的）
UPDATE projects
   SET activity_type = '社团招新',
       cover_tone    = 'photo',
       cover_code    = 'PHOTO / 26',
       cover_title   = '寻找校园里的下一帧光'
 WHERE id = '00000000-0000-4000-8000-000000000201';

-- 自检：
--   SHOW COLUMNS FROM projects LIKE 'cover%';
--   SHOW COLUMNS FROM projects LIKE 'activity_type';
--   SELECT id, activity_type, cover_code, cover_title FROM projects;
