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


def test_default_backend_is_sqlite():
    assert init_db() == "sqlite"
    assert backend_info()["backend"] == "sqlite"


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
