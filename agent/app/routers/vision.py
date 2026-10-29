"""多模态接口：一张海报 -> 结构化活动信息。

三种传法都支持，因为前端在不同阶段会用到不同的一种：
    POST /poster/extract?url=https://...     传图片地址（最省带宽）
    POST /poster/extract   body=图片二进制    Content-Type: image/png（推荐）
    POST /poster/extract   body={"dataUrl": "data:image/png;base64,..."}（前端现成的）

为什么不用 multipart：那需要额外装 python-multipart，少一个依赖少一个挂的地方。
curl 一样能传：curl -X POST --data-binary @poster.png -H "Content-Type: image/png" ...

失败时永远说清楚下一步怎么办：503 = 没配视觉模型（去手动填），422 = 图不行（换一张），
502 = 模型今天不干活（稍后重试）。绝不给用户一个转圈。
"""

from __future__ import annotations

from typing import Any

from fastapi import APIRouter, HTTPException, Query, Request

from app.core.config import get_settings
from app.core.guard import get_rate_limiter
from app.schemas.poster_schema import PosterExtractResponse
from app.services import audit, vision

router = APIRouter(prefix="/poster", tags=["vision"])


def _check_rate(request: Request) -> None:
    client = request.client.host if request.client else "unknown"
    allowed, wait = get_rate_limiter().check(f"poster:{client}")
    if not allowed:
        raise HTTPException(
            status_code=429,
            detail={"code": "RATE_LIMITED", "message": f"请求太频繁，{wait} 秒后再试"},
            headers={"Retry-After": str(wait)},
        )


async def _read_input(request: Request, url: str | None) -> tuple[Any, dict[str, Any]]:
    """把三种输入统一成 (PosterInfo, meta)。"""
    if url:
        return vision.extract_poster_from_url(url)

    body = await request.body()
    if not body:
        raise vision.VisionImageError("请求体是空的：请把图片二进制放在 body 里，或者用 ?url= 传图片地址")

    content_type = (request.headers.get("content-type") or "").lower()
    if content_type.startswith("application/json"):
        try:
            payload = await request.json()
        except ValueError as exc:
            raise vision.VisionImageError(f"JSON 解析失败：{exc}") from exc
        data_url = ""
        if isinstance(payload, dict):
            data_url = str(payload.get("dataUrl") or payload.get("data_url") or "")
        if not data_url:
            raise vision.VisionImageError("JSON 里缺少 dataUrl 字段")
        return vision.extract_poster_from_data_url(data_url)

    mime = content_type.split(";")[0].strip() or None
    return vision.extract_poster(body, mime=mime)


@router.post("/extract", response_model=PosterExtractResponse, summary="解析活动海报")
async def extract(request: Request, url: str | None = Query(default=None, max_length=2000)) -> PosterExtractResponse:
    _check_rate(request)
    settings = get_settings()

    if not settings.vision_enabled:
        raise HTTPException(
            status_code=503,
            detail={
                "code": "VISION_DISABLED",
                "message": "视觉能力已被配置关闭（VISION_ENABLED=false），请手动填写活动信息",
                "next": "manual",
            },
        )

    try:
        info, meta = await _read_input(request, url)
    except vision.VisionNotConfigured as exc:
        audit.log_call(kind="poster", ok=False, flags=["vision_not_configured"], error=str(exc))
        raise HTTPException(
            status_code=503,
            detail={
                "code": "VISION_NOT_CONFIGURED",
                "message": str(exc),
                "next": "manual",
            },
        ) from exc
    except vision.VisionImageError as exc:
        audit.log_call(kind="poster", ok=False, flags=["image_invalid"], error=str(exc))
        raise HTTPException(
            status_code=422,
            detail={"code": "IMAGE_INVALID", "message": str(exc), "next": "retry_with_image"},
        ) from exc
    except vision.VisionFailed as exc:
        audit.log_call(kind="poster", ok=False, flags=["vision_failed"], error=str(exc))
        raise HTTPException(
            status_code=502,
            detail={"code": "VISION_FAILED", "message": str(exc), "next": "retry_later"},
        ) from exc

    audit.log_call(
        kind="poster",
        model=str(meta.get("model") or ""),
        latency_ms=int(meta.get("latencyMs") or 0),
        ok=True,
        flags=list(meta.get("warnings") or [])[:5],
    )

    return PosterExtractResponse(
        ok=True,
        source="vision",
        model=str(meta.get("model") or ""),
        latencyMs=int(meta.get("latencyMs") or 0),
        image={
            "mime": meta.get("mime"),
            "bytes": meta.get("bytes"),
        },
        info=info,
        warnings=list(meta.get("warnings") or []),
    )
