"""知识库接口的数据契约。"""

from __future__ import annotations

from pydantic import BaseModel, Field


class KbSearchRequest(BaseModel):
    query: str = Field(min_length=1, max_length=200, description="检索词")
    k: int = Field(default=4, ge=1, le=10, description="返回条数")
    scene: str = Field(default="", max_length=20, description="场景过滤：recruit/signup/vote/checkin")


class KbHit(BaseModel):
    docId: str
    title: str
    heading: str = ""
    scene: str = ""
    kind: str = ""
    score: float = 0
    vecScore: float = 0
    bm25Score: float = 0
    content: str = ""


class KbSearchResponse(BaseModel):
    query: str
    scene: str = ""
    latencyMs: int = 0
    hits: list[KbHit] = Field(default_factory=list)


class KbRebuildResponse(BaseModel):
    docs: int = 0
    chunks: int = 0
    inserted: int = 0
    deleted: int = 0
    dim: int = 0
    backend: str = ""


class KbStatsResponse(BaseModel):
    chunks: int = 0
    docs: int = 0
    scenes: dict[str, int] = Field(default_factory=dict)
    dim: int = 0
    backend: str = ""
    embedding_backend: str = ""
    enabled: bool = True
