r"""自检脚本：不需要前端、不需要写页面，验证这套骨架是不是活的。

用法：
    .\.venv\Scripts\python.exe selftest.py           # 只查环境、数据库、工具（不花钱）
    .\.venv\Scripts\python.exe selftest.py --live    # 再真调一次模型（会花钱，几厘）

任何一步 FAIL 都会打印堆栈，照着改就行。
"""

from __future__ import annotations

import argparse
import sys
import traceback
from pathlib import Path

# 保证从任意目录运行都能 import 到 app
sys.path.insert(0, str(Path(__file__).resolve().parent))


def step(name: str, fn) -> bool:
    try:
        detail = fn()
    except Exception as exc:  # noqa: BLE001
        print(f"[FAIL] {name}\n       {type(exc).__name__}: {exc}")
        traceback.print_exc()
        return False
    print(f"[ OK ] {name}" + (f"  ->  {detail}" if detail else ""))
    return True


def check_imports() -> str:
    import langchain  # noqa: F401
    import langgraph  # noqa: F401
    import fastapi  # noqa: F401
    from app.main import app  # noqa: F401

    return "langchain / langgraph / fastapi 均可用"


def check_config() -> str:
    from app.core.config import get_settings

    s = get_settings()
    return (
        f"provider={s.llm_provider} model={s.model_name} "
        f"key={'已配置' if s.has_key else '未配置'} db={s.db_path}"
    )


def check_db() -> str:
    from app.db.base import get_conn, init_db

    init_db()
    with get_conn() as conn:
        count = conn.execute("SELECT COUNT(*) AS c FROM activities").fetchone()["c"]
    return f"演示活动 {count} 条"


def check_tools() -> str:
    from app.services.tools import TOOL_MAP

    calc = TOOL_MAP["calculate"].invoke({"expression": "(3+5)*2"})
    stats = TOOL_MAP["query_signup_stats"].invoke({"activity_name": "招新"})
    if "16" not in calc:
        raise RuntimeError(f"calculate 结果不对：{calc}")
    if "已报名" not in stats:
        raise RuntimeError(f"query_signup_stats 结果不对：{stats}")
    return f"4 个工具可用，calculate -> {calc}"


def check_graph_offline() -> str:
    """用假模型跑一遍图，证明「工具循环」这条线是通的（不联网）。"""
    from langchain_core.messages import AIMessage

    from app.services.agent_service import build_agent_graph

    class _StubLLM:
        def bind_tools(self, tools):  # noqa: ANN001
            return self

        def invoke(self, messages):  # noqa: ANN001
            return AIMessage(content="(stub) 图已跑通")

    graph = build_agent_graph(_StubLLM())
    out = graph.invoke({"messages": [("user", "你好")]})
    if not out.get("messages"):
        raise RuntimeError("图没有产出消息")
    return f"节点链正常，产出 {len(out['messages'])} 条消息"


def check_live() -> str:
    from app.services.agent_service import chat

    resp = chat("现在几点了？请调用工具查，别猜。", thread_id="selftest")
    return f"{resp.latency_ms}ms，工具 {[t.name for t in resp.tool_calls]}，回复 {resp.reply[:40]}"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--live", action="store_true", help="真调一次模型（会花钱）")
    args = parser.parse_args()

    print("=" * 60)
    print("环境自检")
    print("=" * 60)

    results = [
        step("1/5 依赖导入", check_imports),
        step("2/5 配置读取", check_config),
        step("3/5 数据库", check_db),
        step("4/5 工具", check_tools),
        step("5/5 智能体图（离线）", check_graph_offline),
    ]

    if args.live:
        results.append(step("6/6 真模型调用", check_live))

    print("=" * 60)
    print(f"通过 {sum(results)}/{len(results)}")
    if not all(results):
        print("有失败项。看上面的堆栈，或者翻 99-踩坑清单。")
        return 1
    if not args.live:
        print("离线检查全过。填好 .env 的 key 后，加 --live 再验一次真模型。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
