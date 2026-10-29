"""数据库查询工具（示例：报名人数）。

这是「让模型能读你自己的数据」的最小示范。
真实项目里换成你的业务表即可，但请守住三条：
1. 只暴露**收窄后**的查询能力，绝不让模型拼 SQL。
2. 查询必须有上限，别让一句"查所有"把库拖死。
3. 只写 ? 占位符，方言交给 app/db/base.py —— SQLite 和 MySQL 两边都能跑。
"""

from __future__ import annotations

from langchain_core.tools import tool

from app.db.base import get_conn

MAX_ROWS = 10


@tool
def query_signup_stats(activity_name: str) -> str:
    """查询某个活动的报名人数和名额。输入活动名称，支持部分匹配，例如「招新」「羽毛球」。"""
    keyword = (activity_name or "").strip()
    if not keyword:
        return "请提供活动名称。"

    with get_conn() as conn:
        rows = conn.fetchall(
            "SELECT name, signups, capacity FROM activities WHERE name LIKE ? LIMIT ?",
            (f"%{keyword}%", MAX_ROWS),
        )

    if not rows:
        return f"没有找到名字包含「{keyword}」的活动。"

    return "\n".join(
        f"{row['name']}：已报名 {row['signups']}/{row['capacity']} 人" for row in rows
    )
