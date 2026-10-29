"""新接口的接口层测试：/kb、/mcp、/audit、/poster。

只测「不花钱也能测的」部分：海报接口故意只喂非法输入，
因为合法图片会真的去调视觉模型。
"""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture(scope="module")
def client():
    with TestClient(app) as c:
        yield c


def test_health_reports_new_capabilities(client):
    body = client.get("/health").json()
    assert body["ok"] is True
    llm = body["llm"]
    assert "vision" in llm and "ready" in llm["vision"]
    assert "rag" in llm
    names = body["tools"]
    for expected in ("draft_page_plan", "validate_page_plan", "search_knowledge", "read_poster_from_url"):
        assert expected in names
    assert "sk-" not in client.get("/health").text


def test_root_lists_new_endpoints(client):
    body = client.get("/").json()
    joined = " ".join(body["endpoints"])
    assert "/poster/extract" in joined
    assert "/mcp/manifest" in joined
    assert "/kb/search" in joined


def test_kb_stats(client):
    data = client.get("/kb/stats").json()
    assert data["chunks"] > 0
    assert data["docs"] >= 8
    assert data["enabled"] is True


def test_kb_search(client):
    response = client.post("/kb/search", json={"query": "招新表单要收哪些字段", "k": 3})
    assert response.status_code == 200
    data = response.json()
    assert data["hits"]
    assert data["hits"][0]["scene"] in ("recruit", "common")
    assert 0 <= data["hits"][0]["score"] <= 2


def test_kb_search_rejects_empty_query(client):
    assert client.post("/kb/search", json={"query": ""}).status_code == 422


def test_kb_rebuild(client):
    data = client.post("/kb/rebuild").json()
    assert data["chunks"] > 0
    assert data["docs"] >= 8


def test_mcp_manifest(client):
    data = client.get("/mcp/manifest").json()
    assert data["protocolVersion"]
    assert len(data["tools"]) >= 9
    assert data["groups"]["product"]


def test_mcp_rpc_tools_list(client):
    response = client.post("/mcp/rpc", json={"jsonrpc": "2.0", "id": 1, "method": "tools/list"})
    data = response.json()
    names = [tool["name"] for tool in data["result"]["tools"]]
    assert "draft_page_plan" in names


def test_mcp_rpc_tools_call(client):
    response = client.post(
        "/mcp/rpc",
        json={
            "jsonrpc": "2.0",
            "id": 2,
            "method": "tools/call",
            "params": {"name": "list_block_types", "arguments": {}},
        },
    )
    result = response.json()["result"]
    assert result["isError"] is False
    assert result["content"][0]["type"] == "text"


def test_audit_logs(client):
    data = client.get("/audit/logs?limit=5").json()
    assert "summary" in data and "logs" in data
    assert isinstance(data["logs"], list)


def test_poster_rejects_empty_body(client):
    response = client.post("/poster/extract", content=b"")
    assert response.status_code == 422
    body = response.json()
    assert body["detail"]["code"] == "IMAGE_INVALID"


def test_poster_rejects_non_image_body(client):
    response = client.post("/poster/extract", content=b"definitely not an image")
    assert response.status_code == 422
    assert response.json()["detail"]["next"] == "retry_with_image"


def test_poster_rejects_json_without_data_url(client):
    response = client.post("/poster/extract", json={"foo": "bar"})
    assert response.status_code == 422
    assert "dataUrl" in response.json()["detail"]["message"]
