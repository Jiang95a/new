"""聊天接口。

只有四种结局，每种都要翻译成明确的状态码，别让前端收到 500 还不知道怎么办：
    200 正常
    422 入参不合法（FastAPI 自动处理）
    502 模型返回异常 / 连续修复失败
    503 没配 key（前端应该走降级路径）
"""

from __future__ import annotations

import json
import logging

from fastapi import APIRouter, HTTPException, Query, Request
from fastapi.responses import StreamingResponse

from app.core.guard import get_rate_limiter
from app.schemas.chat_schema import ChatRequest, ChatResponse, HistoryResponse
from app.services import agent_service, audit
from app.services.llm_client import LLMFormatError, LLMNotConfigured
from app.services.memory.chat_history import get_history

logger = logging.getLogger(__name__)
router = APIRouter(tags=["chat"])


def _check_rate(request: Request, kind: str) -> None:
    """限流只卡花钱的接口。超了给明确状态码和重试时间，别让前端一直转圈。"""
    client = request.client.host if request.client else "unknown"
    allowed, wait = get_rate_limiter().check(f"{kind}:{client}")
    if not allowed:
        raise HTTPException(
            status_code=429,
            detail={"code": "RATE_LIMITED", "message": f"请求太频繁，{wait} 秒后再试"},
            headers={"Retry-After": str(wait)},
        )


@router.post("/chat", response_model=ChatResponse, summary="一问一答")
def chat(req: ChatRequest, request: Request) -> ChatResponse:
    _check_rate(request, "chat")
    try:
        return agent_service.chat(
            message=req.message,
            thread_id=req.thread_id,
            system_extra=req.system_extra,
            temperature=req.temperature,
        )
    except LLMNotConfigured as exc:
        audit.log_call(kind="chat", thread_id=req.thread_id or "", ok=False, error=str(exc))
        raise HTTPException(
            status_code=503,
            detail={"code": "AI_NOT_CONFIGURED", "message": str(exc)},
        ) from exc
    except LLMFormatError as exc:
        audit.log_call(kind="chat", thread_id=req.thread_id or "", ok=False, error=str(exc))
        raise HTTPException(
            status_code=502,
            detail={"code": "AI_FORMAT_ERROR", "message": str(exc)},
        ) from exc
    except HTTPException:
        raise
    except Exception as exc:  # noqa: BLE001
        logger.exception("chat failed")
        audit.log_call(kind="chat", thread_id=req.thread_id or "", ok=False, error=str(exc))
        raise HTTPException(
            status_code=502,
            detail={"code": "AI_FAILED", "message": f"AI 服务异常：{exc}"},
        ) from exc


@router.post("/chat/stream", summary="流式回答（SSE）")
def chat_stream(req: ChatRequest, request: Request) -> StreamingResponse:
    """每行一个 SSE 事件：data: {"delta": "..."}，最后一行 data: [DONE]。

    注意：这个端点用普通 def，但返回的是生成器。FastAPI 会把整个生成过程放在线程池里跑，
    不会阻塞事件循环——这正是我们想要的（模型调用是阻塞的）。
    """
    _check_rate(request, "stream")

    def event_stream():
        try:
            for piece in agent_service.stream_chat(
                message=req.message,
                thread_id=req.thread_id,
                system_extra=req.system_extra,
            ):
                yield f"data: {json.dumps({'delta': piece}, ensure_ascii=False)}\n\n"
            yield "data: [DONE]\n\n"
        except LLMNotConfigured as exc:
            yield f"data: {json.dumps({'error': str(exc), 'code': 'AI_NOT_CONFIGURED'}, ensure_ascii=False)}\n\n"
        except Exception as exc:  # noqa: BLE001
            logger.exception("stream failed")
            yield f"data: {json.dumps({'error': f'流式失败：{exc}', 'code': 'AI_FAILED'}, ensure_ascii=False)}\n\n"

    return StreamingResponse(
        event_stream(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",   # 让 nginx 别缓冲
        },
    )


@router.get("/chat/threads", summary="最近的会话 id")
def list_threads(limit: int = Query(default=20, ge=1, le=100)) -> dict:
    return {"threads": get_history().threads(limit=limit)}


@router.get("/chat/{thread_id}/history", response_model=HistoryResponse, summary="会话历史")
def get_chat_history(
    thread_id: str, limit: int = Query(default=50, ge=1, le=200)
) -> HistoryResponse:
    return HistoryResponse(thread_id=thread_id, messages=get_history().load(thread_id, limit=limit))


@router.delete("/chat/{thread_id}", summary="清空会话")
def clear_chat(thread_id: str) -> dict:
    deleted = get_history().clear(thread_id)
    return {"thread_id": thread_id, "deleted": deleted}
