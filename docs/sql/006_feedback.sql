-- 用户反馈表。可重复执行。
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS feedback_reports (
  id          CHAR(36)     NOT NULL DEFAULT (UUID()),
  user_id     CHAR(36)     NULL,
  category    VARCHAR(32)  NOT NULL DEFAULT 'other',
  content     TEXT         NOT NULL,
  contact     VARCHAR(160) NULL,
  status      VARCHAR(20)  NOT NULL DEFAULT 'open',
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_feedback_user_created (user_id, created_at),
  CONSTRAINT fk_feedback_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE SET NULL,
  CONSTRAINT ck_feedback_status CHECK (status IN ('open', 'resolved', 'closed'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
