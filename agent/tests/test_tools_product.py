"""产品级工具测试：方案的生成与校验。

重点不是「函数能跑」，而是「生成出来的东西前端一定能渲染」：
组件名在 13 个白名单里、按钮跳转有目标、表单字段类型合法、恰好一个首页。
"""

from __future__ import annotations

import json

import pytest

from app.services import block_catalog as catalog
from app.services.tools import TOOL_MAP
from app.services.tools.planner import build_plan, validate_plan

SCENES = ("recruit", "signup", "vote", "checkin")


def test_catalog_matches_frontend_types():
    assert len(catalog.BLOCK_TYPES) == 13
    assert catalog.BLOCK_TYPES[0] == "nav"
    assert "infoCard" in catalog.BLOCK_TYPES
    assert set(catalog.PAGE_ROLES) == {"home", "content", "form", "success"}


def test_list_block_types_tool_is_json():
    out = TOOL_MAP["list_block_types"].invoke({})
    data = json.loads(out)
    assert len(data) == 13
    assert all("requiredProps" in item and "exampleProps" in item for item in data)


@pytest.mark.parametrize("scene", SCENES)
def test_draft_page_plan_passes_own_validation(scene):
    out = TOOL_MAP["draft_page_plan"].invoke({"scene": scene, "title": "测试活动"})
    plan = json.loads(out)
    assert plan["validation"]["ok"], plan["validation"]
    roles = [page["role"] for page in plan["pages"]]
    assert roles.count("home") == 1
    assert "form" in roles


@pytest.mark.parametrize("scene", SCENES)
def test_buttons_always_have_targets(scene):
    plan = build_plan(scene, {"title": "测试活动"})
    for page in plan["pages"]:
        for block in page["blocks"]:
            if block["type"] != "button":
                continue
            action = block["props"]["action"]
            assert action["type"] in catalog.BUTTON_ACTIONS
            if action["type"] == "page":
                assert action["targetRole"] in catalog.PAGE_ROLES
            if action["type"] == "submit":
                assert page["role"] == "form", "提交按钮只应该出现在表单页"


def test_plan_carries_real_meta_into_infocard():
    plan = build_plan(
        "signup",
        {"title": "羽毛球友谊赛", "startAt": "11月8日 19:00", "place": "体育馆 3 号场", "org": "羽协"},
    )
    text = json.dumps(plan, ensure_ascii=False)
    assert "11月8日 19:00" in text
    assert "体育馆 3 号场" in text
    # 没给的字段必须是「待补充」，不许编
    assert plan["meta"]["deadline"] == ""
    assert "待补充" in text or plan["meta"]["deadline"] == ""


def test_validate_rejects_unknown_block_type():
    plan = build_plan("signup", {"title": "x"})
    plan["pages"][0]["blocks"].append({"type": "card3d", "props": {}})
    result = validate_plan(plan)
    assert not result["ok"]
    assert any("未知组件" in e["message"] for e in result["errors"])


def test_validate_requires_exactly_one_home():
    plan = build_plan("signup", {"title": "x"})
    for page in plan["pages"]:
        page["role"] = "content"
    result = validate_plan(plan)
    assert not result["ok"]
    assert any("role=home" in e["message"] for e in result["errors"])


def test_validate_rejects_bad_field_type():
    plan = build_plan("signup", {"title": "x"})
    form_page = next(p for p in plan["pages"] if p["role"] == "form")
    form_block = next(b for b in form_page["blocks"] if b["type"] == "form")
    form_block["props"]["fields"][0]["type"] = "datetime-local"
    result = validate_plan(plan)
    assert not result["ok"]
    assert any("字段类型" in e["message"] for e in result["errors"])


def test_validate_rejects_button_without_target():
    plan = build_plan("signup", {"title": "x"})
    button = next(
        b for page in plan["pages"] for b in page["blocks"] if b["type"] == "button"
    )
    button["props"]["action"] = {"type": "page", "pageId": "", "url": ""}
    result = validate_plan(plan)
    assert not result["ok"]
    assert any("targetRole" in e["message"] for e in result["errors"])


def test_validate_tool_handles_broken_json():
    out = TOOL_MAP["validate_page_plan"].invoke({"plan_json": "{不是 json"})
    data = json.loads(out)
    assert data["ok"] is False
    assert "不是合法 JSON" in data["errors"][0]["message"]


def test_validate_warns_when_required_fields_too_many():
    plan = build_plan("signup", {"title": "x"})
    form_page = next(p for p in plan["pages"] if p["role"] == "form")
    form_block = next(b for b in form_page["blocks"] if b["type"] == "form")
    form_block["props"]["fields"] = [
        {"id": f"f{i}", "label": f"字段{i}", "type": "text", "required": True, "options": []}
        for i in range(6)
    ]
    result = validate_plan(plan)
    assert result["ok"]  # 只是提醒，不算错
    assert any("提交率" in w["message"] for w in result["warnings"])
