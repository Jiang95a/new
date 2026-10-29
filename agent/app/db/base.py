"""数据库访问层：一套接口，两种后端。

    DB_BACKEND=sqlite   零依赖，开发与测试用（默认）
    DB_BACKEND=mysql    联调与部署用，需要 pip install pymysql

写 SQL 的规矩：**统一用 ? 作占位符**，这一层负责翻译成 MySQL 的 %s。
业务代码里不写方言，也就不需要关心后端是哪个。

为什么不用 ORM：这个服务只有一张聊天记录表、一张演示用的活动表。
ORM 会带来迁移目录、模型基类、session 生命周期，收益不抵成本。
真要上，也是后端那边上，不是这里。
"""

from __future__ import annotations

import re
import sqlite3
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Iterable, Iterator

from app.core.config import get_settings


class DBError(RuntimeError):
    """数据库不可用。接口层翻译成 503，别让用户看到裸异常。"""


# ---------------------------------------------------------------------------
# 方言
# ---------------------------------------------------------------------------
SQLITE_DDL: list[str] = [
    """
    CREATE TABLE IF NOT EXISTS messages (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        thread_id  TEXT    NOT NULL,
        role       TEXT    NOT NULL,
        content    TEXT    NOT NULL,
        created_at TEXT    NOT NULL DEFAULT (datetime('now', 'localtime'))
    )
    """,
    "CREATE INDEX IF NOT EXISTS idx_messages_thread ON messages (thread_id, id)",
    """
    CREATE TABLE IF NOT EXISTS activities (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT    NOT NULL UNIQUE,
        signups  INTEGER NOT NULL DEFAULT 0,
        capacity INTEGER NOT NULL DEFAULT 0
    )
    """,
]

# 注意：MySQL 里 utf8 只有 3 字节，中文表情和生僻字会存不进去，必须 utf8mb4。
MYSQL_DDL: list[str] = [
    """
    CREATE TABLE IF NOT EXISTS messages (
        id         BIGINT AUTO_INCREMENT PRIMARY KEY,
        thread_id  VARCHAR(64)  NOT NULL,
        role       VARCHAR(16)  NOT NULL,
        content    MEDIUMTEXT   NOT NULL,
        created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
        KEY idx_messages_thread (thread_id, id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """,
    """
    CREATE TABLE IF NOT EXISTS activities (
        id       INT AUTO_INCREMENT PRIMARY KEY,
        name     VARCHAR(128) NOT NULL UNIQUE,
        signups  INT          NOT NULL DEFAULT 0,
        capacity INT          NOT NULL DEFAULT 0
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """,
]

DEMO_ACTIVITIES = [
    ("摄影社招新", 37, 60),
    ("羽毛球友谊赛", 24, 32),
    ("周六图书馆志愿者", 11, 20),
]

_SAFE_IDENT = re.compile(r"^[A-Za-z0-9_]{1,64}$")


def to_dialect(sql: str, backend: str) -> str:
    """把占位符翻译成目标方言。标识符和值都不在这里拼，只换占位符。"""
    if backend == "mysql":
        return sql.replace("?", "%s")
    return sql


# ---------------------------------------------------------------------------
# 连接外壳
# ---------------------------------------------------------------------------
class Conn:
    """把 sqlite3 和 pymysql 的差异收进这一个类。

    对外只暴露四个动作，全部返回「可当字典用」的结果。
    """

    def __init__(self, raw: Any, backend: str) -> None:
        self._raw = raw
        self.backend = backend

    def execute(self, sql: str, params: Iterable[Any] = ()) -> int:
        cur = self._raw.cursor()
        cur.execute(to_dialect(sql, self.backend), tuple(params))
        return cur.rowcount or 0

    def executemany(self, sql: str, seq: Iterable[Iterable[Any]]) -> int:
        cur = self._raw.cursor()
        cur.executemany(to_dialect(sql, self.backend), list(seq))
        return cur.rowcount or 0

    def fetchall(self, sql: str, params: Iterable[Any] = ()) -> list[dict[str, Any]]:
        cur = self._raw.cursor()
        cur.execute(to_dialect(sql, self.backend), tuple(params))
        return [dict(row) for row in cur.fetchall()]

    def fetchone(self, sql: str, params: Iterable[Any] = ()) -> dict[str, Any] | None:
        rows = self.fetchall(sql, params)
        return rows[0] if rows else None


# ---------------------------------------------------------------------------
# 连接与建表
# ---------------------------------------------------------------------------
def db_path() -> Path:
    """SQLite 的相对路径解析成绝对路径，并保证目录存在。"""
    raw = Path(get_settings().db_path)
    path = raw if raw.is_absolute() else Path.cwd() / raw
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


def _mysql_connect(settings) -> Any:  # noqa: ANN001
    try:
        import pymysql
        import pymysql.cursors
    except ImportError as exc:  # pragma: no cover - 环境缺包
        raise DBError("DB_BACKEND=mysql 但没装 pymysql：pip install pymysql") from exc

    name = settings.db_name
    if not _SAFE_IDENT.match(name):
        raise DBError(f"DB_NAME 只能包含字母数字下划线：{name!r}")

    def _connect(database: str | None) -> Any:
        return pymysql.connect(
            host=settings.db_host,
            port=settings.db_port,
            user=settings.db_user,
            password=settings.db_password,
            database=database,
            charset="utf8mb4",
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=False,
            connect_timeout=5,
        )

    try:
        return _connect(name)
    except pymysql.err.OperationalError as exc:
        # 1049 = Unknown database。库不存在就自动建一个，省得每人手动跑一遍。
        if exc.args and exc.args[0] == 1049:
            try:
                server = _connect(None)
                try:
                    with server.cursor() as cur:
                        cur.execute(
                            f"CREATE DATABASE IF NOT EXISTS `{name}` "
                            "DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
                        )
                    server.commit()
                finally:
                    server.close()
                return _connect(name)
            except Exception as inner:  # noqa: BLE001
                raise DBError(
                    f"连上 MySQL 但建库失败（{settings.db_host}:{settings.db_port}）：{inner}"
                ) from inner
        raise DBError(
            f"连不上 MySQL（{settings.db_host}:{settings.db_port}）：{exc}。"
            "检查服务是否启动、账号密码、以及 DB_BACKEND 是否写对。"
        ) from exc
    except Exception as exc:  # noqa: BLE001
        raise DBError(f"连不上 MySQL（{settings.db_host}:{settings.db_port}）：{exc}") from exc


@contextmanager
def get_conn() -> Iterator[Conn]:
    """每次用每次开，用完就关。

    出错自动回滚——别让半截写入留在库里。
    """
    settings = get_settings()

    if settings.db_backend == "mysql":
        raw = _mysql_connect(settings)
        conn = Conn(raw, "mysql")
        try:
            yield conn
            raw.commit()
        except Exception:
            raw.rollback()
            raise
        finally:
            raw.close()
        return

    raw = sqlite3.connect(db_path(), check_same_thread=False)
    raw.row_factory = sqlite3.Row
    conn = Conn(raw, "sqlite")
    try:
        yield conn
        raw.commit()
    except Exception:
        raw.rollback()
        raise
    finally:
        raw.close()


def init_db() -> str:
    """建表 + 塞演示数据。重复执行安全（IF NOT EXISTS / INSERT IGNORE）。

    返回实际使用的后端名，方便自检和日志打印。
    """
    settings = get_settings()
    backend = settings.db_backend

    if backend == "mysql":
        ddl, seed = MYSQL_DDL, "INSERT IGNORE INTO activities (name, signups, capacity) VALUES (?, ?, ?)"
    else:
        ddl, seed = SQLITE_DDL, "INSERT OR IGNORE INTO activities (name, signups, capacity) VALUES (?, ?, ?)"

    with get_conn() as conn:
        for stmt in ddl:
            conn.execute(stmt)
        conn.executemany(seed, DEMO_ACTIVITIES)
    return backend


def backend_info() -> dict[str, Any]:
    """当前连的是哪个库、连在哪里（不含密码）。"""
    settings = get_settings()
    if settings.db_backend == "mysql":
        return {
            "backend": "mysql",
            "target": f"{settings.db_host}:{settings.db_port}/{settings.db_name}",
        }
    return {"backend": "sqlite", "target": str(db_path())}
