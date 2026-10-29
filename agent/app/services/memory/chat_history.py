"""聊天记录存取。

只做三件事：追加、按会话读最近 N 条、清空。
不做摘要、不做向量检索——那是「变动」的部分。

后半句别省：**同样的代码，SQLite 和 MySQL 都能跑。**
方言翻译在 app/db/base.py 里，这里只写 ? 占位符。

为什么聊天记录不放在 LangGraph 的 checkpoint 里：
checkpoint 的职责是「图执行到哪一步了」，用来续跑和回放；
聊天记录的职责是「用户和助手说过什么」，用来给接口查。两件事别混。
"""

from __future__ import annotations

from functools import lru_cache

from app.db.base import get_conn
from app.schemas.chat_schema import ChatMessage

_VALID_ROLES = {"system", "user", "assistant", "tool"}


class ChatHistory:
    def append(self, thread_id: str, role: str, content: str) -> None:
        if not thread_id or not content:
            return
        if role not in _VALID_ROLES:
            role = "assistant"
        with get_conn() as conn:
            conn.execute(
                "INSERT INTO messages (thread_id, role, content) VALUES (?, ?, ?)",
                (thread_id, role, content),
            )

    def load(self, thread_id: str, limit: int | None = None) -> list[ChatMessage]:
        """按时间正序返回最近 limit 条。limit 为空则全取。"""
        sql = "SELECT role, content FROM messages WHERE thread_id = ? ORDER BY id DESC"
        params: list[object] = [thread_id]
        if limit and limit > 0:
            sql += " LIMIT ?"
            params.append(int(limit))

        with get_conn() as conn:
            rows = conn.fetchall(sql, params)

        # 上面是倒序取的（为了拿到「最近」），这里翻回正序
        return [
            ChatMessage(role=row["role"], content=row["content"]) for row in reversed(rows)
        ]

    def clear(self, thread_id: str) -> int:
        with get_conn() as conn:
            return conn.execute("DELETE FROM messages WHERE thread_id = ?", (thread_id,))

    def threads(self, limit: int = 20) -> list[str]:
        with get_conn() as conn:
            rows = conn.fetchall(
                "SELECT thread_id, MAX(id) AS last_id FROM messages "
                "GROUP BY thread_id ORDER BY last_id DESC LIMIT ?",
                (int(limit),),
            )
        return [row["thread_id"] for row in rows]


@lru_cache(maxsize=1)
def get_history() -> ChatHistory:
    return ChatHistory()
