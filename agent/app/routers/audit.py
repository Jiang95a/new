"""审计接口：把 AI 调用记录摊开给评审看。

这一页就是「AI 安全与可控性」最直接的可解释性证据：
什么时候调的、哪个模型、多少毫秒、有没有被护栏拦、失败了几次。
"""

from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Query

from app.services import audit

router = APIRouter(prefix="/audit", tags=["audit"])


@router.get("/logs", summary="最近的 AI 调用记录")
def logs(limit: int = Query(default=20, ge=1, le=200)) -> dict[str, Any]:
    return {"summary": audit.summary(), "logs": audit.recent(limit)}
