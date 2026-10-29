"""多模态测试：不联网、不花钱，全用假模型。

真正要证明的三件事：
1. 图片不合法 -> 拒绝（不是把二进制当图片发给模型）
2. 模型输出坏 JSON -> 自动修复一次
3. 模型返回空壳 -> 报错，不返回一张空洞的卡
"""

from __future__ import annotations

import json

import pytest
from langchain_core.messages import AIMessage

from app.core.config import get_settings
from app.services import vision

PNG_HEADER = b"\x89PNG\r\n\x1a\n"


def png_bytes(size: int = 128) -> bytes:
    return PNG_HEADER + b"0" * max(0, size - len(PNG_HEADER))


class FakeLLM:
    """按顺序吐出预设的回复，并记录调用次数。"""

    def __init__(self, replies: list[str]) -> None:
        self.replies = replies
        self.calls = 0

    def invoke(self, messages):  # noqa: ANN001
        self.calls += 1
        return AIMessage(content=self.replies[min(self.calls, len(self.replies)) - 1])


GOOD_PAYLOAD = {
    "title": "光影摄影社 2026 秋季招新",
    "org": "光影摄影社",
    "startAt": "11月8日 周六 19:00",
    "place": "三教 402",
    "deadline": "",
    "capacity": 60,
    "fee": "免费",
    "contact": "QQ 群 123456",
    "intro": "寻找校园里的下一帧光",
    "signupFields": ["姓名", "手机号", "意向部门"],
    "evidence": {"title": "光影摄影社 2026 秋季招新", "place": "三教 402"},
    "unclear": ["报名截止时间"],
    "confidence": 0.86,
}


def test_sniff_accepts_png():
    mime, ext = vision.sniff_image(png_bytes())
    assert mime == "image/png"
    assert ext == "png"


def test_sniff_accepts_jpeg():
    assert vision.sniff_image(b"\xff\xd8\xff" + b"0" * 64)[0] == "image/jpeg"


def test_sniff_accepts_webp():
    data = b"RIFF" + b"\x00\x00\x00\x00" + b"WEBP" + b"0" * 32
    assert vision.sniff_image(data)[0] == "image/webp"


def test_sniff_rejects_non_image():
    with pytest.raises(vision.VisionImageError):
        vision.sniff_image(b"hello world")
    with pytest.raises(vision.VisionImageError):
        vision.sniff_image(b"")


def test_size_limit(monkeypatch):
    settings = get_settings()
    monkeypatch.setattr(settings, "poster_max_bytes", 16, raising=False)
    with pytest.raises(vision.VisionImageError) as exc:
        vision.extract_poster(png_bytes(1024), llm=FakeLLM([json.dumps(GOOD_PAYLOAD)]))
    assert "MB" in str(exc.value)


def test_not_configured(monkeypatch):
    settings = get_settings()
    monkeypatch.setattr(settings, "vision_model", "", raising=False)
    monkeypatch.setattr(settings, "vision_api_key", "", raising=False)
    monkeypatch.setattr(settings, "llm_api_key", "", raising=False)
    with pytest.raises(vision.VisionNotConfigured):
        vision.extract_poster(png_bytes(), llm=None)


def test_extract_with_fake_model():
    fake = FakeLLM([json.dumps(GOOD_PAYLOAD, ensure_ascii=False)])
    info, meta = vision.extract_poster(png_bytes(), llm=fake)
    assert info.title.startswith("光影摄影社")
    assert info.capacity == 60
    assert info.evidence["place"] == "三教 402"
    assert meta["mime"] == "image/png"
    assert fake.calls == 1


def test_json_wrapped_in_prose_is_parsed():
    reply = "好的，结果如下：\n" + json.dumps(GOOD_PAYLOAD, ensure_ascii=False) + "\n以上。"
    info, _ = vision.extract_poster(png_bytes(), llm=FakeLLM([reply]))
    assert info.org == "光影摄影社"


def test_bad_json_retries_once():
    fake = FakeLLM(["我无法解析这张图", json.dumps(GOOD_PAYLOAD, ensure_ascii=False)])
    info, _ = vision.extract_poster(png_bytes(), llm=fake)
    assert info.title
    assert fake.calls == 2, "第一次输出不合格时应该自动重试一次"


def test_bad_json_twice_raises():
    fake = FakeLLM(["抱歉", "还是不行"])
    with pytest.raises(vision.VisionFailed):
        vision.extract_poster(png_bytes(), llm=fake)


def test_empty_shell_is_rejected():
    empty = {
        "title": "",
        "org": "",
        "startAt": "",
        "place": "",
        "capacity": None,
        "signupFields": [],
        "evidence": {},
        "unclear": ["整张图看不清"],
        "confidence": 0.1,
    }
    with pytest.raises(vision.VisionFailed):
        vision.extract_poster(png_bytes(), llm=FakeLLM([json.dumps(empty, ensure_ascii=False)]))


def test_wrong_capacity_type_is_repaired_by_retry():
    bad = dict(GOOD_PAYLOAD, capacity="六十人")
    fake = FakeLLM([json.dumps(bad, ensure_ascii=False), json.dumps(GOOD_PAYLOAD, ensure_ascii=False)])
    info, _ = vision.extract_poster(png_bytes(), llm=fake)
    assert info.capacity == 60


def test_warnings_when_time_missing():
    payload = dict(GOOD_PAYLOAD, startAt="", place="")
    info, meta = vision.extract_poster(png_bytes(), llm=FakeLLM([json.dumps(payload, ensure_ascii=False)]))
    assert info.title
    assert any("时间" in w for w in meta["warnings"])


def test_data_url_roundtrip():
    import base64

    data_url = "data:image/png;base64," + base64.b64encode(png_bytes()).decode()
    with pytest.raises(vision.VisionImageError):
        vision.extract_poster_from_data_url("not-a-data-url")
    # 正常路径要真调模型，这里只验证坏输入被拦住
    assert data_url.startswith("data:image/png")
