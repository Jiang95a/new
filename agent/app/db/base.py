"""SQLite 连接与建表。

用的是标准库 sqlite3，不引入 ORM——学生项目没必要，而且调试时 sqlite3 更直观。
换成 MySQL/Postgres 时，只需要改这个文件，业务层不用动。
"""

from __future__ import annotations

import sqlite3
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator

from app.core.config import get_settings

# 注意：messages 表是「聊天记录」，不是 LangGraph 的 checkpoint。
# 两者职责不同：这个表给接口层读，checkpoint 给图续跑用。
SCHEMA = """
CREATE TABLE IF NOT EXISTS messages (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    thread_id TEXT    NOT NULL,
    role      TEXT    NOT NULL,
    content   TEXT    NOT NULL,
    created_at TEXT   NOT NULL DEFAULT (datetime('now', 'localtime'))
);
CREATE INDEX IF NOT EXISTS idx_messages_thread ON messages (thread_id, id);

CREATE TABLE IF NOT EXISTS activities (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    name     TEXT    NOT NULL UNIQUE,
    signups  INTEGER NOT NULL DEFAULT 0,
    capacity INTEGER NOT NULL DEFAULT 0
);
"""

DEMO_ACTIVITIES = [
    ("摄影社招新", 37, 60),
    ("羽毛球友谊赛", 24, 32),
    ("周六图书馆志愿者", 11, 20),
]


def db_path() -> Path:
    """把配置里的相对路径解析成绝对路径，并保证目录存在。"""
    raw = Path(get_settings().db_path)
    path = raw if raw.is_absolute() else Path.cwd() / raw
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


@contextmanager
def get_conn() -> Iterator[sqlite3.Connection]:
    """每次用每次开，用完就关。SQLite 的开销比你想的小，别提前优化。"""
    conn = sqlite3.connect(db_path(), check_same_thread=False)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
        conn.commit()
    finally:
        conn.close()


def init_db() -> None:
    """建表 + 塞几条演示数据。重复执行是安全的（IF NOT EXISTS / INSERT OR IGNORE）。"""
    with get_conn() as conn:
        conn.executescript(SCHEMA)
        conn.executemany(
            "INSERT OR IGNORE INTO activities (name, signups, capacity) VALUES (?, ?, ?)",
            DEMO_ACTIVITIES,
        )
