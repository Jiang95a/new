-- ============================================================================
-- 第 0 步：建库 + 建专用账号（需要用 root 或管理员执行，只需跑一次）
--
--   mysql -u root -p < docs/sql/00_create_database.sql
--
-- 为什么要独立账号：
--   后端服务和 AI 服务都不该用 root。这里只给它自己那个库的读写 + 建表权限，
--   拿不到别的库、也删不了库。这是最小权限原则，也是出事时唯一能止损的东西。
-- ============================================================================

-- 库：字符集必须 utf8mb4（utf8 只有 3 字节，存不下表情符和生僻字）
CREATE DATABASE IF NOT EXISTS campus_diy
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

-- 专用账号（本机访问）
--   ⚠ 密码改成你自己的，且必须满足 MySQL 8 默认策略：
--     至少 8 位，含大写、小写、数字，建议再带符号
--   ⚠ 只用字母数字下划线，别用 # ! @ 空格——写进 .env 时容易被截断
CREATE USER IF NOT EXISTS 'campus_app'@'localhost' IDENTIFIED BY 'Campus_2026';
ALTER USER 'campus_app'@'localhost' IDENTIFIED BY 'Campus_2026';

-- 只给这个库的权限：查/写/建表/建索引，不给 DROP DATABASE、不给别的库
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, REFERENCES
  ON campus_diy.* TO 'campus_app'@'localhost';

FLUSH PRIVILEGES;

-- 验证：用新账号登一次，应该能进去
--   mysql -u campus_app -p campus_diy

-- ============================================================================
-- 常见错误：
--   1819 Your password does not satisfy the current policy requirements
--        → 密码太弱，换 8 位以上带大小写数字的
--   1396 Operation CREATE USER failed
--        → 账号已存在但密码不一致，用上面的 ALTER USER 覆盖
--   1044 Access denied for user 'campus_app'@'localhost' to database 'campus_diy'
--        → GRANT 没生效或库名写错，重跑一次 GRANT + FLUSH PRIVILEGES
-- ============================================================================
