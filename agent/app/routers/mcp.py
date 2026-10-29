"""MCP 接口（HTTP 传输）。

MCP 本来走 stdio，但浏览器和 Postman 连不上 stdio，所以这里再开一个 HTTP 传输，
用的是**同一个 dispatcher**（app/mcp/registry.py），不是两套实现。

    GET  /mcp/manifest  —— 自描述：协议版本、服务名、全部工具及其 inputSchema
    POST /mcp/rpc       —— 直接发 JSON-RPC，例如 {"jsonrpc":"2.0","id":1,"method":"tools/list"}

演示话术：这把「Agent 与工作流」「MCP 与工具集成」两项从"我说我做了"变成"你现场点一下"。
"""

from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Body

from app.mcp import registry

router = APIRouter(prefix="/mcp", tags=["mcp"])


@router.get("/manifest", summary="MCP 能力清单")
def manifest() -> dict[str, Any]:
    return registry.manifest()


@router.post("/rpc", summary="JSON-RPC 入口（与 stdio 共用同一实现）")
def rpc(payload: dict[str, Any] = Body(...)) -> dict[str, Any]:
    result = registry.dispatch(payload)
    if result is None:
        # 通知类消息按规范不必回复，但 HTTP 需要一个明确的响应体
        return {"jsonrpc": "2.0", "id": payload.get("id"), "result": {"acknowledged": True}}
    return result
