"""数据库层测试：方言翻译 + 默认 SQLite 下的读写。

MySQL 的集成测试不放在这里——它需要一台真库，属于联调阶段的事。
这里只保证：SQL 方言翻译正确、默认后端能跑、记录读写正确。
"""

from __future__ import annotations

from app.db.base import backend_info, get_conn, init_db, to_dialect


def test_dialect_sqlite_untouched():
    assert to_dialect("SELECT ? , ?", "sqlite") == "SELECT ? , ?"


def test_dialect_mysql_translates():
    assert to_dialect("SELECT ? , ?", "mysql") == "SELECT %s , %s"


def test_default_backend_is_sqlite(monkeypatch):
    """默认后端是 sqlite。

    注意：这台机器的 agent/.env 里配了 DB_BACKEND=mysql，所以不能直接断言 init_db()。
    这里构造一个**不读 .env 文件**的 Settings 来验证「默认值」，再验证当前环境自洽。
    """
    from app.core.config import Settings, get_settings

    monkeypatch.delenv("DB_BACKEND", raising=False)
    default = Settings(_env_file=None)
    assert default.db_backend == "sqlite"

    current = get_settings().db_backend
    assert init_db() == current
    assert backend_info()["backend"] == current


def test_read_write_roundtrip():
    init_db()
    name = "_测试活动_"
    with get_conn() as conn:
        conn.execute("DELETE FROM activities WHERE name = ?", (name,))
        conn.execute(
            "INSERT INTO activities (name, signups, capacity) VALUES (?, ?, ?)",
            (name, 3, 9),
        )
        row = conn.fetchone(
            "SELECT signups, capacity FROM activities WHERE name = ?", (name,)
        )
        assert row == {"signups": 3, "capacity": 9}
        conn.execute("DELETE FROM activities WHERE name = ?", (name,))


def test_like_and_limit_work():
    init_db()
    with get_conn() as conn:
        rows = conn.fetchall(
            "SELECT name FROM activities WHERE name LIKE ? LIMIT ?", ("%招新%", 5)
        )
    assert rows and all("招新" in r["name"] for r in rows)
