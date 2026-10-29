"""知识库接口：检索、看统计、重建索引。

这三个接口的作用不是给 C 端用的，是给「演示 + 答辩 + 联调」用的：
    POST /kb/search   —— 现场敲一句「招新表单该收什么」，直接看到命中哪几块资料
    GET  /kb/stats    —— 库里有几个文档、几块、几个场景
    POST /kb/rebuild  —— 改完 data/knowledge 下的 md，一条命令重建
"""

from __future__ import annotations

import time

from fastapi import APIRouter, HTTPException

from app.schemas.kb_schema import (
    KbHit,
    KbRebuildResponse,
    KbSearchRequest,
    KbSearchResponse,
    KbStatsResponse,
)
from app.services.rag import retriever, store
from app.services.rag.embedding import EmbeddingError

router = APIRouter(prefix="/kb", tags=["knowledge"])


@router.post("/search", response_model=KbSearchResponse, summary="检索知识库")
def search(req: KbSearchRequest) -> KbSearchResponse:
    started = time.perf_counter()
    hits = retriever.search(req.query, k=req.k, scene=req.scene or None)
    return KbSearchResponse(
        query=req.query,
        scene=req.scene or retriever.detect_scene(req.query),
        latencyMs=int((time.perf_counter() - started) * 1000),
        hits=[KbHit(**hit.as_dict()) for hit in hits],
    )


@router.get("/stats", response_model=KbStatsResponse, summary="知识库统计")
def stats() -> KbStatsResponse:
    return KbStatsResponse(**retriever.stats())


@router.post("/rebuild", response_model=KbRebuildResponse, summary="重建索引（改完语料后调用）")
def rebuild() -> KbRebuildResponse:
    try:
        result = store.rebuild()
    except EmbeddingError as exc:
        raise HTTPException(
            status_code=502,
            detail={"code": "EMBEDDING_FAILED", "message": str(exc)},
        ) from exc
    except Exception as exc:  # noqa: BLE001 - 建库失败要给明确原因
        raise HTTPException(
            status_code=503,
            detail={"code": "KB_REBUILD_FAILED", "message": f"重建索引失败：{exc}"},
        ) from exc
    return KbRebuildResponse(**result)
