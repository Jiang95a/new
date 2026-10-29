"""页面组件的 Python 镜像。

为什么要抄一份前端目录过来：agent 产出的页面方案必须能被前端**直接渲染**。
前端认的是这 13 个受控组件（web/src/types/editor.ts 的 BLOCK_TYPES），
agent 这边如果多造一个类型、少写一个必填属性，前端就只能丢掉它。

所以这份文件的唯一职责是「和前端对齐」，改的时候两边一起改：
    web/src/data/blockCatalog.ts  ←→  app/services/block_catalog.py

规矩：这里只描述「能填什么」，不描述「长什么样」。样式是前端的事。
"""

from __future__ import annotations

import secrets
from typing import Any, Final

# 顺序和前端完全一致，方便肉眼 diff
BLOCK_TYPES: Final[tuple[str, ...]] = (
    "nav",
    "banner",
    "heading",
    "text",
    "image",
    "infoCard",
    "button",
    "form",
    "radio",
    "checkbox",
    "qrcode",
    "divider",
    "countdown",
)

PAGE_ROLES: Final[tuple[str, ...]] = ("home", "content", "form", "success")

FIELD_TYPES: Final[tuple[str, ...]] = (
    "text",
    "tel",
    "email",
    "textarea",
    "select",
    "radio",
    "checkbox",
)

INFO_ICONS: Final[tuple[str, ...]] = ("time", "place", "org", "people", "ticket", "contact")

BUTTON_ACTIONS: Final[tuple[str, ...]] = ("page", "url", "submit", "none")

BUTTON_VARIANTS: Final[tuple[str, ...]] = ("primary", "outline", "soft")

HEADING_SIZES: Final[tuple[str, ...]] = ("xl", "lg", "md")
TEXT_SIZES: Final[tuple[str, ...]] = ("md", "sm")
IMAGE_RATIOS: Final[tuple[str, ...]] = ("4:3", "1:1", "16:9", "3:4")

BLOCK_META: Final[dict[str, dict[str, str]]] = {
    "nav": {"label": "导航栏", "group": "布局", "desc": "顶部标题栏，每页只有一个"},
    "banner": {"label": "Banner", "group": "布局", "desc": "首屏主视觉，放活动名和一句话简介"},
    "divider": {"label": "分割线", "group": "布局", "desc": "分隔内容段落"},
    "heading": {"label": "标题", "group": "内容", "desc": "章节标题"},
    "text": {"label": "文本", "group": "内容", "desc": "段落说明，一段话不超过 120 字"},
    "image": {"label": "图片", "group": "内容", "desc": "单张配图"},
    "infoCard": {"label": "信息卡片", "group": "内容", "desc": "时间、地点、主办等信息行"},
    "button": {"label": "按钮", "group": "互动", "desc": "跳转页面、打开链接或提交表单"},
    "qrcode": {"label": "二维码", "group": "互动", "desc": "扫码查看，留空则用发布链接"},
    "countdown": {"label": "倒计时", "group": "互动", "desc": "报名截止提醒"},
    "form": {"label": "表单", "group": "表单", "desc": "收集报名信息，一页最多一个"},
    "radio": {"label": "单选框", "group": "表单", "desc": "单选问题"},
    "checkbox": {"label": "多选框", "group": "表单", "desc": "多选问题"},
}

# 每个组件「必须有的属性」与「属性允许的取值」。校验器就靠这张表。
REQUIRED_PROPS: Final[dict[str, tuple[str, ...]]] = {
    "nav": ("title",),
    "banner": ("title",),
    "heading": ("text",),
    "text": ("text",),
    "image": (),
    "infoCard": ("items",),
    "button": ("text", "action"),
    "form": ("fields",),
    "radio": ("question", "options"),
    "checkbox": ("question", "options"),
    "qrcode": (),
    "divider": (),
    "countdown": (),
}


def new_id(prefix: str) -> str:
    """和前端 uid() 一样的目的：短、唯一、能看出来是谁的 id。"""
    return f"{prefix}_{secrets.token_hex(4)}"


def is_block_type(value: Any) -> bool:
    return isinstance(value, str) and value in BLOCK_TYPES


def default_props(block_type: str, meta: dict[str, Any] | None = None) -> dict[str, Any]:
    """给每个组件一份「能立刻渲染」的默认属性。

    meta 里带了活动信息时优先用真实信息，缺的才留占位——
    占位文案统一写成「待补充」，前端质量检查会把它标出来。
    """
    info = meta or {}
    start_at = str(info.get("startAt") or "待补充")
    place = str(info.get("place") or "待补充")
    org = str(info.get("org") or "待补充")
    capacity = info.get("capacity")
    deadline = str(info.get("deadline") or "")

    if block_type == "nav":
        return {"title": str(info.get("title") or "活动标题"), "right": "", "showBack": True}

    if block_type == "banner":
        return {
            "title": str(info.get("title") or "在这里写主标题"),
            "subtitle": str(info.get("subtitle") or "一句话说清这是什么活动"),
            "image": "",
            "height": 220,
        }

    if block_type == "heading":
        return {"text": "章节标题", "sub": "", "size": "lg"}

    if block_type == "text":
        return {"text": str(info.get("intro") or "在这里写活动介绍。"), "size": "md"}

    if block_type == "image":
        return {"url": "", "caption": "", "ratio": "4:3"}

    if block_type == "infoCard":
        items = [
            {"id": new_id("it"), "icon": "time", "label": "时间", "value": start_at},
            {"id": new_id("it"), "icon": "place", "label": "地点", "value": place},
            {"id": new_id("it"), "icon": "org", "label": "主办", "value": org},
        ]
        if capacity:
            items.append(
                {
                    "id": new_id("it"),
                    "icon": "people",
                    "label": "名额",
                    "value": f"{int(capacity)} 人",
                }
            )
        return {"title": "活动信息", "items": items}

    if block_type == "button":
        return {
            "text": str(info.get("buttonText") or "立即报名"),
            "variant": "primary",
            "full": True,
            "action": {"type": "page", "pageId": "", "url": ""},
        }

    if block_type == "form":
        fields = info.get("fields")
        if not isinstance(fields, list) or not fields:
            fields = [
                {
                    "id": new_id("f"),
                    "label": "姓名",
                    "type": "text",
                    "required": True,
                    "placeholder": "请输入姓名",
                    "options": [],
                },
                {
                    "id": new_id("f"),
                    "label": "手机号",
                    "type": "tel",
                    "required": True,
                    "placeholder": "用于接收活动通知",
                    "options": [],
                },
            ]
        return {
            "title": str(info.get("formTitle") or "报名信息"),
            "buttonText": "提交报名",
            "successHint": str(info.get("successHint") or "提交后我们会通知你"),
            "fields": fields,
        }

    if block_type == "radio":
        options = info.get("options")
        return {
            "question": str(info.get("question") or "请选择"),
            "options": options if isinstance(options, list) and len(options) >= 2 else ["选项一", "选项二"],
            "required": True,
            "hint": "",
        }

    if block_type == "checkbox":
        options = info.get("options")
        return {
            "question": str(info.get("question") or "可多选"),
            "options": options if isinstance(options, list) and len(options) >= 2 else ["选项一", "选项二"],
            "required": False,
            "max": 0,
            "hint": "",
        }

    if block_type == "qrcode":
        return {"url": "", "label": "扫码查看活动详情", "size": 132}

    if block_type == "divider":
        return {"label": ""}

    if block_type == "countdown":
        return {"target": deadline, "label": "距离报名截止", "doneText": "报名已截止"}

    return {}


def catalog_digest() -> list[dict[str, Any]]:
    """给模型看的说明书：类型、用途、必填属性。工具 list_block_types 就返回它。"""
    out: list[dict[str, Any]] = []
    for block_type in BLOCK_TYPES:
        meta = BLOCK_META.get(block_type, {})
        out.append(
            {
                "type": block_type,
                "label": meta.get("label", block_type),
                "group": meta.get("group", ""),
                "desc": meta.get("desc", ""),
                "requiredProps": list(REQUIRED_PROPS.get(block_type, ())),
                "exampleProps": default_props(block_type, {}),
            }
        )
    return out
