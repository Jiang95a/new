"""冒烟测试：不联网、不花钱，验证骨架是活的。

这些测试的意义：你改完代码跑一下，10 秒知道有没有把自己写崩。
"""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services.memory.chat_history import get_history
from app.services.tools import TOOL_MAP


@pytest.fixture()
def client():
    with TestClient(app) as c:
        yield c


def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    body = r.json()
    assert body["ok"] is True
    assert "calculate" in body["tools"]
    # key 绝不能被返回
    assert "sk-" not in r.text


def test_root(client):
    assert client.get("/").status_code == 200


def test_chat_rejects_empty_message(client):
    r = client.post("/chat", json={"message": ""})
    assert r.status_code == 422


def test_history_roundtrip():
    history = get_history()
    tid = "test-thread"
    history.clear(tid)
    history.append(tid, "user", "你好")
    history.append(tid, "assistant", "在")
    messages = history.load(tid)
    assert [m.content for m in messages] == ["你好", "在"]
    assert [m.role for m in messages] == ["user", "assistant"]
    history.clear(tid)


def test_calculate_tool():
    out = TOOL_MAP["calculate"].invoke({"expression": "(3+5)*2"})
    assert out.endswith("16")


def test_calculate_rejects_code():
    out = TOOL_MAP["calculate"].invoke({"expression": "__import__('os').system('dir')"})
    assert "失败" in out


def test_activity_stats_tool():
    out = TOOL_MAP["get_activity_stats"].invoke({"keyword": "招新"})
    assert "已报名" in out
    # 演示数据必须如实标注，不许冒充真实报名数
    assert "演示数据" in out


def test_activity_stats_missing():
    out = TOOL_MAP["get_activity_stats"].invoke({"keyword": "不存在的活动xyz"})
    assert "没有查到" in out
    assert "不要" in out  # 明确要求模型别编数字


def test_graph_loop_offline():
    """用假模型验证：模型请求调工具 → 工具执行 → 模型拿到结果 → 收尾。"""
    from langchain_core.messages import AIMessage, ToolMessage

    from app.services.agent_service import build_agent_graph

    class _Stub:
        def __init__(self):
            self.calls = 0

        def bind_tools(self, tools):  # noqa: ANN001
            return self

        def invoke(self, messages):  # noqa: ANN001
            self.calls += 1
            if self.calls == 1:
                return AIMessage(
                    content="",
                    tool_calls=[
                        {"name": "calculate", "args": {"expression": "2+3"}, "id": "call_1"}
                    ],
                )
            return AIMessage(content="结果是 5")

    graph = build_agent_graph(_Stub())
    out = graph.invoke({"messages": [("user", "2+3 等于几")]})

    assert any(isinstance(m, ToolMessage) for m in out["messages"])
    assert out["messages"][-1].content == "结果是 5"
