"""MCP 测试：协议层 + stdio 传输层 + 真起一个子进程。

最后那个子进程测试是刻意的：如果 `python -m app.mcp.stdio_server` 起不来，
评委的 Claude Desktop 也起不来——所以我在这里真起一次，喂三条消息，看回得对不对。
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

from app.mcp import registry
from app.mcp.stdio_server import handle_line

AGENT_ROOT = Path(__file__).resolve().parents[1]


def test_manifest_lists_all_tools():
    data = registry.manifest()
    assert data["protocolVersion"] == registry.PROTOCOL_VERSION
    assert data["serverInfo"]["name"] == registry.SERVER_NAME
    names = [tool["name"] for tool in data["tools"]]
    assert "draft_page_plan" in names
    assert "search_knowledge" in names
    assert "read_poster_from_url" in names
    for tool in data["tools"]:
        assert tool["inputSchema"]["type"] == "object"
        assert tool["description"].strip(), f"{tool['name']} 没有描述，模型不知道什么时候用"


def test_initialize():
    response = registry.dispatch({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}})
    assert response["result"]["protocolVersion"] == registry.PROTOCOL_VERSION
    assert "tools" in response["result"]["capabilities"]


def test_tools_list():
    response = registry.dispatch({"jsonrpc": "2.0", "id": 2, "method": "tools/list"})
    names = [tool["name"] for tool in response["result"]["tools"]]
    assert "calculate" in names


def test_tools_call_works():
    response = registry.dispatch(
        {
            "jsonrpc": "2.0",
            "id": 3,
            "method": "tools/call",
            "params": {"name": "calculate", "arguments": {"expression": "(3+5)*2"}},
        }
    )
    text = response["result"]["content"][0]["text"]
    assert text.endswith("16")
    assert response["result"]["isError"] is False


def test_tools_call_with_product_tool():
    response = registry.dispatch(
        {
            "jsonrpc": "2.0",
            "id": 4,
            "method": "tools/call",
            "params": {"name": "list_block_types", "arguments": {}},
        }
    )
    payload = json.loads(response["result"]["content"][0]["text"])
    assert len(payload) == 13


def test_tools_call_unknown_tool_is_soft_error():
    response = registry.dispatch(
        {"jsonrpc": "2.0", "id": 5, "method": "tools/call", "params": {"name": "nope", "arguments": {}}}
    )
    assert response["result"]["isError"] is True
    assert "未知工具" in response["result"]["content"][0]["text"]


def test_unknown_method_is_jsonrpc_error():
    response = registry.dispatch({"jsonrpc": "2.0", "id": 6, "method": "resources/list"})
    assert response["error"]["code"] == -32601


def test_notification_gets_no_reply():
    assert registry.dispatch({"jsonrpc": "2.0", "method": "notifications/initialized"}) is None
    assert handle_line('{"jsonrpc":"2.0","method":"notifications/initialized"}') is None


def test_handle_line_parse_error():
    response = handle_line("{坏掉的 json")
    assert response["error"]["code"] == -32700


def test_handle_line_ignores_blank():
    assert handle_line("   ") is None


def test_stdio_server_runs_as_subprocess():
    """真起一个进程，走一遍 initialize -> tools/list -> tools/call。"""
    requests = [
        {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}},
        {"jsonrpc": "2.0", "method": "notifications/initialized"},
        {"jsonrpc": "2.0", "id": 2, "method": "tools/list"},
        {
            "jsonrpc": "2.0",
            "id": 3,
            "method": "tools/call",
            "params": {"name": "calculate", "arguments": {"expression": "2**10"}},
        },
    ]
    stdin = "\n".join(json.dumps(r, ensure_ascii=False) for r in requests) + "\n"

    completed = subprocess.run(
        [sys.executable, "-m", "app.mcp.stdio_server"],
        input=stdin,
        capture_output=True,
        text=True,
        encoding="utf-8",
        cwd=str(AGENT_ROOT),
        timeout=60,
    )
    assert completed.returncode == 0, completed.stderr[-2000:]

    lines = [line for line in completed.stdout.splitlines() if line.strip()]
    # 3 条请求里有 1 条是通知，所以只应该有 3 条响应... 实际是 initialize/list/call = 3
    assert len(lines) == 3, completed.stdout
    payloads = [json.loads(line) for line in lines]
    assert payloads[0]["result"]["protocolVersion"] == registry.PROTOCOL_VERSION
    assert any("draft_page_plan" in tool["name"] for tool in payloads[1]["result"]["tools"])
    assert payloads[2]["result"]["content"][0]["text"].endswith("1024")
    # stdout 只许出现协议消息，日志必须走 stderr
    assert "[mcp]" not in completed.stdout
