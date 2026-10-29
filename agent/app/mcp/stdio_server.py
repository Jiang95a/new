"""MCP stdio 传输层：一行一个 JSON-RPC，读 stdin、写 stdout。

用法（给支持 MCP 的客户端，例如 Claude Desktop / Cursor 配置里）：
    command: <项目路径>\\agent\\.venv\\Scripts\\python.exe
    args:    ["-m", "app.mcp.stdio_server"]
    cwd:     <项目路径>\\agent

手动试一下也行：
    echo {"jsonrpc":"2.0","id":1,"method":"tools/list"} | python -m app.mcp.stdio_server

三条硬规矩：
1. stdout 只能写协议消息，任何日志都走 stderr——否则客户端解析直接崩。
2. 一行一条消息，处理完立刻 flush，不然客户端会一直等。
3. 单条消息出错只回 error，绝不让进程退出。
"""

from __future__ import annotations

import json
import sys
from typing import Any

from app.mcp.registry import dispatch


def handle_line(line: str) -> dict[str, Any] | None:
    """把一行文本变成一条响应。空行、坏 JSON 都返回 None（不该回的就别回）。"""
    text = (line or "").strip()
    if not text:
        return None
    try:
        payload = json.loads(text)
    except ValueError:
        return {
            "jsonrpc": "2.0",
            "id": None,
            "error": {"code": -32700, "message": "Parse error"},
        }

    if isinstance(payload, list):
        # 规范允许批量，但我们只处理单条，按 Invalid Request 回，避免静默丢消息
        return {
            "jsonrpc": "2.0",
            "id": None,
            "error": {"code": -32600, "message": "批量请求不支持，请逐条发送"},
        }
    return dispatch(payload)


def _force_utf8() -> None:
    """把 stdin/stdout 强制成 UTF-8。

    MCP 规范要求 UTF-8，而 Windows 的 sys.stdout 默认是 GBK：
    不显式改，中文工具结果要么变乱码，要么直接抛 UnicodeEncodeError。
    这不是"顺手优化"，是这套东西在 Windows 上能不能用的前提。
    """
    for stream in (sys.stdin, sys.stdout):
        try:
            stream.reconfigure(encoding="utf-8", newline="\n")  # type: ignore[attr-defined]
        except (AttributeError, ValueError):  # pragma: no cover - 测试里注入 StringIO 会走到这
            pass


def serve(stdin=None, stdout=None) -> None:  # noqa: ANN001 - 便于测试注入
    source = stdin or sys.stdin
    sink = stdout or sys.stdout

    if stdin is None and stdout is None:
        _force_utf8()

    for line in source:
        response = handle_line(line)
        if response is None:
            continue
        sink.write(json.dumps(response, ensure_ascii=False) + "\n")
        sink.flush()


def main() -> int:
    print("[mcp] stdio server ready", file=sys.stderr)
    try:
        serve()
    except KeyboardInterrupt:  # pragma: no cover - 手动运行时才有
        return 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
