"""多模态：把一张活动海报读成结构化字段。

这是产品故事的主干——「上传一张海报，生成一个能报名的页面」。
主干断了，剩下的都是装饰。所以这个模块有两条铁律：

1. **认不出就说认不出**。没配视觉模型 -> 503；图不是图片 -> 422；
   模型说图里没有时间 -> startAt 留空，并写进 unclear。绝不拿"看起来合理"的值填空。
2. **每个字段都要能指回图上原文**。evidence 字段存的就是证据，
   前端可以让用户逐个核对，这比"AI 很准"可信得多。

分隔符说明：主模型用 deepseek 也行，但海报解析必须是能读图的模型
（qwen-vl / glm-4v / gpt-4o），所以视觉模型单独一套配置，见 config.vision_*。
"""

from __future__ import annotations

import base64
import json
import logging
import time
from typing import Any

import httpx
from langchain_core.messages import HumanMessage, SystemMessage
from pydantic import ValidationError

from app.core.config import get_settings
from app.schemas.poster_schema import PosterInfo

logger = logging.getLogger(__name__)

MAX_EDGE_NOTE = "图片最长边建议 1600px 以内，过大的图会增加延迟"


class VisionError(RuntimeError):
    """视觉链路的基类异常。接口层按类型翻译成不同状态码。"""


class VisionNotConfigured(VisionError):
    """没配视觉模型。接口层 -> 503，前端走手动填写，不能卡住用户。"""


class VisionImageError(VisionError):
    """图不是图、太大、或拿不到。接口层 -> 422。"""


class VisionFailed(VisionError):
    """模型调不通或返回看不懂。接口层 -> 502。"""


# 魔数表：不信任客户端给的 content-type，自己看文件头
_MAGIC: list[tuple[bytes, str, str]] = [
    (b"\x89PNG\r\n\x1a\n", "image/png", "png"),
    (b"\xff\xd8\xff", "image/jpeg", "jpg"),
    (b"GIF87a", "image/gif", "gif"),
    (b"GIF89a", "image/gif", "gif"),
]


def sniff_image(data: bytes) -> tuple[str, str]:
    """返回 (mime, 扩展名)。认不出来就抛 VisionImageError。"""
    if not data:
        raise VisionImageError("图片是空的")
    for magic, mime, ext in _MAGIC:
        if data.startswith(magic):
            return mime, ext
    if data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return "image/webp", "webp"
    raise VisionImageError("这不是 PNG/JPG/WEBP/GIF 图片，或者文件已经损坏")


def _check_size(data: bytes) -> None:
    limit = get_settings().poster_max_bytes
    if len(data) > limit:
        raise VisionImageError(f"图片超过 {limit // 1024 // 1024}MB，请压缩后再传")


VISION_SYSTEM_PROMPT = """你是活动海报信息抽取器。你的唯一任务是把海报上**真实存在**的信息抽取成 JSON。

铁则：
1. 只输出一个 JSON 对象，不要解释、不要 markdown 代码块。
2. 没写的字段一律给空字符串/空数组，并把字段名写进 unclear。**绝对不许推测或补全。**
3. capacity 只在海报明确写了数字（如「限 60 人」「60 个名额」）时才填整数，否则填 null。
4. 每个非空字段都要在 evidence 里给出它在海报上的原文片段，最多 30 字。
5. 时间统一成「11月8日 周六 19:00」的格式；海报只写日期就只输出日期，不要自己加时段。
6. 最后给 confidence（0~1）：能清楚读出主要信息给 0.8 以上，图糊/字小/大面积艺术字给 0.3 以下。

JSON 结构：
{
  "title": "活动名称",
  "org": "主办方全称",
  "startAt": "开始时间",
  "place": "地点",
  "deadline": "报名截止时间",
  "capacity": 60 或 null,
  "fee": "费用（免费就写免费）",
  "contact": "联系方式/群号",
  "intro": "海报上的一句宣传语",
  "signupFields": ["海报要求填写的信息"],
  "evidence": {"title": "海报原文片段"},
  "unclear": ["读不清或缺失的字段说明"],
  "confidence": 0.0
}"""


def _build_vision_llm() -> Any:
    settings = get_settings()
    if not settings.vision_ready:
        raise VisionNotConfigured(
            "没有配置可用的视觉模型。请在 .env 设置 VISION_MODEL（例如 qwen-vl-max / glm-4v-plus / gpt-4o）"
            "以及 VISION_API_KEY（也可以复用 LLM_API_KEY），然后重启服务。"
        )

    try:
        from langchain_openai import ChatOpenAI
    except ImportError as exc:  # pragma: no cover - 依赖没装
        raise VisionFailed("langchain-openai 未安装，无法调用视觉模型") from exc

    return ChatOpenAI(
        model=settings.vision_model.strip(),
        api_key=settings.vision_api_key_value,
        base_url=settings.vision_base_url_value,
        temperature=0.0,
        timeout=settings.vision_timeout,
        max_retries=1,
        max_tokens=1024,
    )


def _content_to_text(content: Any) -> str:
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts: list[str] = []
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                parts.append(str(block.get("text", "")))
        return "".join(parts)
    return str(content or "")


def _extract_json_object(text: str) -> dict[str, Any] | None:
    """从回复里抠出第一个完整的 JSON 对象（允许前后有解释文字）。"""
    start = text.find("{")
    if start < 0:
        return None
    depth = 0
    in_string = False
    escaped = False
    for index in range(start, len(text)):
        char = text[index]
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            continue
        if char == '"':
            in_string = True
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                try:
                    parsed = json.loads(text[start : index + 1])
                except ValueError:
                    return None
                return parsed if isinstance(parsed, dict) else None
    return None


def _call_vision(llm: Any, data_url: str, extra_instruction: str = "") -> str:
    human_text = "抽取这张海报里的活动信息，按约定的 JSON 结构输出。"
    if extra_instruction:
        human_text += f"\n\n上一次输出不合格，请修正：{extra_instruction}"

    message = HumanMessage(
        content=[
            {"type": "text", "text": human_text},
            {"type": "image_url", "image_url": {"url": data_url}},
        ]
    )
    try:
        response = llm.invoke([SystemMessage(content=VISION_SYSTEM_PROMPT), message])
    except Exception as exc:  # noqa: BLE001 - 网络/额度/模型名错都收在这里
        raise VisionFailed(f"视觉模型调用失败：{exc}") from exc
    return _content_to_text(getattr(response, "content", response))


def _post_check(info: PosterInfo, warnings: list[str]) -> None:
    """模型给了一份空壳，就等于没解析成功——宁可报错，也不返回一张空洞的卡。"""
    if not (info.title or info.startAt or info.place or info.org):
        raise VisionFailed("海报里没有识别到任何有效的活动信息，请换一张更清晰的图或手动填写")

    if not info.title:
        warnings.append("没认出活动名称，请手动补充")
    if not info.startAt:
        warnings.append("没认出开始时间")
    if not info.place:
        warnings.append("没认出地点")
    if info.confidence < 0.5:
        warnings.append(f"模型自评把握不大（confidence={info.confidence:.2f}），请逐项核对")


def extract_poster(
    image_bytes: bytes,
    *,
    mime: str | None = None,
    llm: Any = None,
) -> tuple[PosterInfo, dict[str, Any]]:
    """核心入口。llm 可注入假模型，测试不联网、不花钱。

    返回 (结构化信息, 元数据)。元数据里有模型名、耗时、告警，用来填响应体。
    """
    settings = get_settings()
    started = time.perf_counter()

    _check_size(image_bytes)
    detected_mime, ext = sniff_image(image_bytes)
    final_mime = mime if (mime or "").startswith("image/") and mime == detected_mime else detected_mime

    client = llm if llm is not None else _build_vision_llm()
    data_url = f"data:{final_mime};base64,{base64.b64encode(image_bytes).decode('ascii')}"

    raw = _call_vision(client, data_url)
    payload = _extract_json_object(raw)

    info: PosterInfo | None = None
    error_note = ""
    if payload is None:
        error_note = "输出里没有找到合法的 JSON 对象"
    else:
        try:
            info = PosterInfo.model_validate(payload)
        except ValidationError as exc:
            # 把校验错误喂回去再试一次：模型最常犯的是 capacity 给了字符串
            error_note = str(exc)[:400]

    if info is None:
        retry_raw = _call_vision(client, data_url, extra_instruction=error_note or "请只输出合法 JSON")
        retry_payload = _extract_json_object(retry_raw)
        if retry_payload is None:
            raise VisionFailed("模型两次都没有输出可解析的 JSON，请稍后重试")
        try:
            info = PosterInfo.model_validate(retry_payload)
        except ValidationError as exc:
            raise VisionFailed(f"模型输出的字段类型不符合约定：{str(exc)[:300]}") from exc

    warnings: list[str] = []
    _post_check(info, warnings)

    meta = {
        "model": settings.vision_model.strip(),
        "latencyMs": int((time.perf_counter() - started) * 1000),
        "mime": final_mime,
        "ext": ext,
        "bytes": len(image_bytes),
        "warnings": warnings,
    }
    return info, meta


def extract_poster_from_url(url: str, *, timeout: float = 15.0) -> tuple[PosterInfo, dict[str, Any]]:
    """从 URL 取图再解析。先下载再解析，不让模型去猜外链能不能访问。"""
    if not url.lower().startswith(("http://", "https://")):
        raise VisionImageError("只支持 http(s) 图片地址")

    limit = get_settings().poster_max_bytes
    try:
        with httpx.stream("GET", url, timeout=timeout, follow_redirects=True) as response:
            response.raise_for_status()
            chunks: list[bytes] = []
            total = 0
            for piece in response.iter_bytes():
                total += len(piece)
                if total > limit:
                    raise VisionImageError(f"远程图片超过 {limit // 1024 // 1024}MB")
                chunks.append(piece)
            data = b"".join(chunks)
    except httpx.HTTPError as exc:
        raise VisionImageError(f"图片下载失败：{exc}") from exc

    return extract_poster(data)


def extract_poster_from_data_url(data_url: str) -> tuple[PosterInfo, dict[str, Any]]:
    """兼容前端直接把图片转成 base64 传上来的情况。"""
    if not data_url.startswith("data:"):
        raise VisionImageError("data URL 必须以 data: 开头")
    try:
        header, _, body = data_url.partition(",")
        mime = header[5:].split(";")[0]
        data = base64.b64decode(body, validate=True)
    except Exception as exc:  # noqa: BLE001
        raise VisionImageError(f"base64 解码失败：{exc}") from exc
    return extract_poster(data, mime=mime)
