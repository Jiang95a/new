"""工具：知识库检索。

这是 RAG 的「工具形态」——模型可以主动决定"我要先查一下规范"。
同时 agent_service 里还会做一次自动检索（被动形态），两条路共用同一个 store，
所以不会出现"工具查到的"和"自动注入的"不一致。
"""

from __future__ import annotations

from langchain_core.tools import tool

from app.services.rag import retriever


@tool
def search_knowledge(query: str, scene: str = "") -> str:
    """检索本地知识库：页面结构、文案规范、表单设计、移动端视觉、合规审核要点。

    什么时候用：设计页面结构、写文案、定表单字段、检查合规时，先查一遍再回答。
    query 用中文关键词，例如「招新表单必填项」「正文一行最多多少字」。
    scene 可选：recruit / signup / vote / checkin，留空则自动判断。
    返回的是资料原文，引用时请说明来自哪一份资料。
    """
    return retriever.search_as_text(query, scene=scene or None)
