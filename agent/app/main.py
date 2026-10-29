r"""FastAPI 入口。

启动：
    .\start.ps1
或者：
    .\.venv\Scripts\python.exe -m uvicorn app.main:app --reload --port 8000

然后打开 http://127.0.0.1:8000/docs
"""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app import __version__
from app.core.config import get_settings
from app.db.base import init_db
from app.routers import chat as chat_router
from app.schemas.chat_schema import HealthResponse
from app.services.tools import ALL_TOOLS

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)-7s %(name)s | %(message)s",
)
logger = logging.getLogger("app")


@asynccontextmanager
async def lifespan(_: FastAPI):
    # 启动时做：建表、打印配置摘要（不含 key）、提示缺什么
    init_db()
    settings = get_settings()
    logger.info("配置就绪：provider=%s model=%s", settings.llm_provider, settings.model_name)
    if not settings.has_key:
        logger.warning("未配置 LLM_API_KEY —— /chat 会返回 503，其余接口正常")
    logger.info("工具已注册：%s", ", ".join(t.name for t in ALL_TOOLS))
    yield
    logger.info("服务已停止")


settings = get_settings()
app = FastAPI(
    title="校园活动智能体服务",
    version=__version__,
    description="聊天接口 + 工具调用 + 会话记忆。给前端/后端对接用。",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat_router.router)


@app.get("/health", response_model=HealthResponse, tags=["meta"], summary="探活")
def health() -> HealthResponse:
    current = get_settings()
    return HealthResponse(
        ok=True,
        app=current.app_name,
        llm=current.safe_summary(),
        tools=[tool.name for tool in ALL_TOOLS],
    )


@app.get("/", tags=["meta"], summary="服务信息")
def index() -> dict:
    return {
        "service": settings.app_name,
        "version": __version__,
        "docs": "/docs",
        "health": "/health",
        "endpoints": ["POST /chat", "POST /chat/stream", "GET /chat/{thread_id}/history"],
    }
