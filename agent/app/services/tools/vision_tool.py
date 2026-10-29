"""工具：读海报（多模态）。

模型自己看不到图，但可以调这个工具把图读成文字。
工具永远返回字符串、永远不抛异常——视觉模型挂了，对话不能跟着挂。
"""

from __future__ import annotations

import json

from langchain_core.tools import tool

from app.services import vision


@tool
def read_poster_from_url(url: str) -> str:
    """读取一张活动海报（图片 URL），抽取出活动名称、时间、地点、主办、名额、报名要求。

    什么时候用：用户发了一个图片链接，或者问「这张海报写了什么」「帮我按这个海报建页面」。
    返回 JSON。没认出某个字段就是空字符串，**不要自己补**；需要补的字段写进 unclear。
    """
    if not str(url or "").strip():
        return "没有给图片地址。"

    try:
        info, meta = vision.extract_poster_from_url(url)
    except vision.VisionNotConfigured as exc:
        return f"读图功能暂时不可用：{exc}（可以请用户手动填写活动信息）"
    except vision.VisionImageError as exc:
        return f"这张图读不了：{exc}"
    except vision.VisionFailed as exc:
        return f"读图失败了：{exc}"

    payload = info.model_dump()
    payload["_meta"] = {"model": meta.get("model"), "warnings": meta.get("warnings", [])}
    return json.dumps(payload, ensure_ascii=False, indent=2)
