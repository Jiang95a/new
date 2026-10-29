"""RAG 包：语料、向量、存储、检索。

对外只暴露这几个名字，别的都是内部实现：
    knowledge_message(query)  -> 给模型注入的 system 文本 + 命中列表
    search_as_text(query)     -> 给工具用的纯文本结果
    stats()                   -> 库里有几块、几个场景
"""

from __future__ import annotations

from app.services.rag import corpus, embedding, store  # noqa: F401  (顺序重要：store 依赖 corpus/embedding)
from app.services.rag.retriever import (  # noqa: F401
    build_context,
    detect_scene,
    knowledge_message,
    search,
    search_as_text,
    stats,
)

__all__ = [
    "build_context",
    "detect_scene",
    "knowledge_message",
    "search",
    "search_as_text",
    "stats",
    "store",
    "corpus",
    "embedding",
]
