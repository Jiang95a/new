"""联网搜索工具（ddgs）。

注意两件事：
1. 联网搜索会失败——没网、被墙、被限流。所以它必须永远返回字符串，不许抛异常。
2. 搜索结果要截断。原文塞回模型只会烧 token，还会把无关信息喂进去。
"""

from __future__ import annotations

import logging

from langchain_core.tools import tool

logger = logging.getLogger(__name__)

MAX_RESULTS = 5


@tool
def search_web(query: str) -> str:
    """联网搜索公开信息。适合查实时资讯、校园公告、某个活动的最新消息。不要用它查常识。"""
    try:
        from ddgs import DDGS
    except ImportError:  # pragma: no cover - 环境缺包时的兜底
        return "联网搜索不可用：未安装 ddgs（pip install ddgs）。"

    try:
        with DDGS() as ddgs:
            try:
                items = ddgs.text(query, max_results=MAX_RESULTS)
            except TypeError:
                # ddgs 早期版本参数名是 keywords
                items = ddgs.text(keywords=query, max_results=MAX_RESULTS)
    except Exception as exc:  # noqa: BLE001
        logger.warning("search_web failed: %s", exc)
        return f"搜索失败（可能没网或被限流）：{exc}"

    if not items:
        return "没有搜到相关结果，换个说法再试。"

    lines = []
    for item in items[:MAX_RESULTS]:
        title = str(item.get("title", ""))[:60]
        body = str(item.get("body", "")).replace("\n", " ")[:120]
        href = str(item.get("href", ""))[:120]
        lines.append(f"- {title}：{body}（{href}）")
    return "\n".join(lines)
