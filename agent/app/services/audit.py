"""AI 调用审计。

为什么要有这张表：评委问「你怎么证明 AI 可控」，最硬的一句回答是
「每一次模型调用都留了记录：谁、什么时间、跑的哪个模型、多少毫秒、有没有被护栏拦」。
比"我们做了安全检查"具体得多。

写日志永远不许影响主流程：这里所有函数都吞异常。
"""

from __future__ import annotations

import logging
from typing import Any

from app.db.base import get_conn

logger = logging.getLogger(__name__)

MAX_FLAG_LEN = 250


def log_call(
    *,
    kind: str,
    thread_id: str = "",
    model: str = "",
    latency_ms: int = 0,
    ok: bool = True,
    flags: list[str] | None = None,
    error: str = "",
) -> None:
    """记一次调用。kind: chat / stream / poster / tool。"""
    try:
        with get_conn() as conn:
            conn.execute(
                "INSERT INTO ai_call_logs (thread_id, kind, model, latency_ms, ok, flags, error) "
                "VALUES (?, ?, ?, ?, ?, ?, ?)",
                (
                    (thread_id or "")[:64],
                    (kind or "unknown")[:32],
                    (model or "")[:128],
                    int(latency_ms or 0),
                    1 if ok else 0,
                    ",".join(flags or [])[:MAX_FLAG_LEN],
                    (error or "")[:500],
                ),
            )
    except Exception as exc:  # noqa: BLE001 - 审计失败不能影响业务
        logger.warning("写审计日志失败：%s", exc)


def recent(limit: int = 20) -> list[dict[str, Any]]:
    with get_conn() as conn:
        rows = conn.fetchall(
            "SELECT id, thread_id, kind, model, latency_ms, ok, flags, error, created_at "
            "FROM ai_call_logs ORDER BY id DESC LIMIT ?",
            (max(1, min(200, int(limit))),),
        )
    for row in rows:
        row["ok"] = bool(row.get("ok"))
        row["flags"] = [f for f in str(row.get("flags") or "").split(",") if f]
    return rows


def summary() -> dict[str, Any]:
    with get_conn() as conn:
        total = conn.fetchone(
            "SELECT COUNT(*) AS c, COALESCE(SUM(CASE WHEN ok = 0 THEN 1 ELSE 0 END), 0) AS f, "
            "COALESCE(AVG(latency_ms), 0) AS avg FROM ai_call_logs"
        ) or {}
        blocked = conn.fetchone(
            "SELECT COUNT(*) AS c FROM ai_call_logs WHERE flags LIKE ?", ("%blocked%",)
        ) or {}
    return {
        "calls": int(total.get("c") or 0),
        "failed": int(total.get("f") or 0),
        "avgLatencyMs": int(float(total.get("avg") or 0)),
        "blocked": int(blocked.get("c") or 0),
    }
