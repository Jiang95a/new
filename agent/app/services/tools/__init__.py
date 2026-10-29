"""工具注册表。

加一个工具只需要两步：
1. 在 tools/ 下新建文件，用 @tool 写函数
2. 在下面 import 并加进 ALL_TOOLS

别在这里写业务逻辑。
"""

from __future__ import annotations

from langchain_core.tools import BaseTool

from app.services.tools.db_query import query_signup_stats
from app.services.tools.search import search_web
from app.services.tools.utility import calculate, get_current_time

ALL_TOOLS: list[BaseTool] = [
    get_current_time,
    calculate,
    search_web,
    query_signup_stats,
]

TOOL_MAP: dict[str, BaseTool] = {tool.name: tool for tool in ALL_TOOLS}
