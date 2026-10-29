"""工具注册表。

加一个工具只需要两步：
1. 在 tools/ 下新建文件，用 @tool 写函数（docstring 是给模型看的说明书，必须写"什么时候用"）
2. 在下面 import 并加进 ALL_TOOLS

别在这里写业务逻辑。

工具清单（答辩时按这个顺序讲）：
    产品动作  draft_page_plan / validate_page_plan / list_block_types
    多模态    read_poster_from_url
    知识库    search_knowledge
    数据      get_activity_stats
    基础      get_current_time / calculate / search_web
"""

from __future__ import annotations

from langchain_core.tools import BaseTool

from app.services.tools.knowledge import search_knowledge
from app.services.tools.planner import draft_page_plan, list_block_types, validate_page_plan
from app.services.tools.search import search_web
from app.services.tools.stats import get_activity_stats
from app.services.tools.utility import calculate, get_current_time
from app.services.tools.vision_tool import read_poster_from_url

ALL_TOOLS: list[BaseTool] = [
    # 产品动作：页面方案的生成与校验，这才是「Agent 在做产品的事」
    list_block_types,
    draft_page_plan,
    validate_page_plan,
    # 多模态与知识库
    read_poster_from_url,
    search_knowledge,
    # 数据
    get_activity_stats,
    # 基础能力
    get_current_time,
    calculate,
    search_web,
]

TOOL_MAP: dict[str, BaseTool] = {tool.name: tool for tool in ALL_TOOLS}

# 按用途分组，MCP manifest 和 README 都用它来展示
TOOL_GROUPS: dict[str, list[str]] = {
    "product": ["list_block_types", "draft_page_plan", "validate_page_plan"],
    "multimodal": ["read_poster_from_url"],
    "knowledge": ["search_knowledge"],
    "data": ["get_activity_stats"],
    "utility": ["get_current_time", "calculate", "search_web"],
}
