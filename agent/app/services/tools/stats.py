"""工具：查活动报名数据。

旧版这里查的是一张 agent 自己种的假表，模型会理直气壮报一个编出来的数字——
那比"不知道"危险得多。现在改成：

1. 只读 activity_stats，这张表由后端从 projects / form_submissions 汇总后同步进来；
2. 每一行都带 is_demo 标记，演示数据必须在回答里如实说明「演示数据」；
3. 查不到就说查不到，并明确要求模型不要推测数字。
"""

from __future__ import annotations

import json
from typing import Any

from langchain_core.tools import tool

from app.db.base import get_conn

MAX_ROWS = 5


def query_stats(keyword: str) -> list[dict[str, Any]]:
    """按名称或 slug 模糊查。返回原始行，供工具和接口共用。"""
    key = (keyword or "").strip()
    if not key:
        return []
    like = f"%{key}%"
    with get_conn() as conn:
        rows = conn.fetchall(
            "SELECT slug, title, signups, capacity, is_demo, synced_at "
            "FROM activity_stats WHERE title LIKE ? OR slug LIKE ? LIMIT ?",
            (like, like, MAX_ROWS),
        )
    return rows


def format_rows(rows: list[dict[str, Any]]) -> str:
    if not rows:
        return (
            "没有查到匹配的活动数据。请直接告诉用户「我这边查不到这个活动的报名数据」，"
            "并建议他去项目后台看；**不要估计或编造任何数字**。"
        )

    lines: list[str] = []
    has_demo = False
    for row in rows:
        title = row.get("title") or row.get("slug")
        signups = int(row.get("signups") or 0)
        capacity = int(row.get("capacity") or 0)
        demo = bool(row.get("is_demo"))
        has_demo = has_demo or demo

        if capacity > 0:
            body = f"已报名 {signups}/{capacity} 人，还剩 {max(0, capacity - signups)} 个名额"
        else:
            body = f"已报名 {signups} 人（不限名额）"
        if demo:
            body += "（演示数据）"
        lines.append(f"- {title}（{row.get('slug')}）：{body}")

    head = "查到以下活动的报名情况："
    if has_demo:
        head += "\n注意：标记为「演示数据」的行不是真实报名数据，回答时必须如实说明。"
    return head + "\n" + "\n".join(lines)


@tool
def get_activity_stats(keyword: str) -> str:
    """查询某个活动当前的报名人数和名额。输入活动名称或拼音短名（如「招新」「photo-club」）。

    什么时候用：用户问「现在报了多少人了」「还剩几个名额」。
    查不到就如实说查不到，**绝对不要推测数字**。
    """
    try:
        return format_rows(query_stats(keyword))
    except Exception as exc:  # noqa: BLE001 - 工具永远不抛异常
        return f"查询失败（数据库可能不可用）：{exc}。请告诉用户稍后再试。"


def stats_summary() -> dict[str, Any]:
    """给 /health 和自检看：这张表里到底有多少行、多少是演示数据。"""
    with get_conn() as conn:
        row = conn.fetchone(
            "SELECT COUNT(*) AS c, COALESCE(SUM(is_demo), 0) AS d FROM activity_stats"
        ) or {}
    return {"rows": int(row.get("c") or 0), "demo_rows": int(row.get("d") or 0)}


def to_json(rows: list[dict[str, Any]]) -> str:
    return json.dumps(rows, ensure_ascii=False, default=str)
