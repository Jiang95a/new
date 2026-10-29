"""MCP 包：协议实现与 stdio 传输。"""

from __future__ import annotations

from app.mcp.registry import call_tool, dispatch, list_tools, manifest, server_info  # noqa: F401

__all__ = ["call_tool", "dispatch", "list_tools", "manifest", "server_info"]
