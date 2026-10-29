"""模型客户端：建模型 + 结构化输出兜底。

这个文件是「固定代码」里最值钱的一个：
它把"模型偶尔不听话"挡在业务代码外面，你的 services 层永远是干净的。
"""

from __future__ import annotations

from typing import Any

from langchain_core.messages import AIMessage, HumanMessage, SystemMessage
from langchain_openai import ChatOpenAI
from pydantic import BaseModel

from app.core.config import get_settings


class LLMNotConfigured(RuntimeError):
    """没配 key。接口层要把它翻译成 503，让前端走降级路径。"""


class LLMFormatError(RuntimeError):
    """结构化输出连续修复失败。接口层翻译成 502。"""


def build_llm(
    *,
    temperature: float | None = None,
    max_tokens: int | None = None,
    streaming: bool = False,
) -> ChatOpenAI:
    """按配置造一个聊天模型。所有参数集中在这儿，别处不要直接 new ChatOpenAI。"""
    settings = get_settings()
    if not settings.has_key:
        raise LLMNotConfigured(
            "未配置 LLM_API_KEY。请在项目根目录的 .env 里填写后重启服务。"
        )

    return ChatOpenAI(
        model=settings.model_name,
        api_key=settings.llm_api_key,
        base_url=settings.base_url,
        temperature=settings.llm_temperature if temperature is None else temperature,
        timeout=settings.llm_timeout,
        max_retries=2,
        max_tokens=max_tokens or settings.llm_max_tokens,
        streaming=streaming,
    )


def call_structured(
    schema: type[BaseModel],
    *,
    system: str,
    user: str,
    llm: Any = None,
    retries: int = 1,
) -> BaseModel:
    """要求模型输出符合 schema 的对象；格式不对就把错误喂回去再试一次。

    为什么只重试 1 次：格式错误大多是模型没看懂 schema，再试 3 次也是白烧钱。
    还不行说明是 schema 或提示词的问题，该改代码，不是加重试。
    """
    client = llm if llm is not None else build_llm()
    chain = client.with_structured_output(schema, include_raw=True)
    messages: list[Any] = [SystemMessage(content=system), HumanMessage(content=user)]

    out = chain.invoke(messages)
    if out["parsed"] is not None:
        return out["parsed"]

    for _ in range(max(0, retries)):
        raw = out["raw"]
        raw_text = getattr(raw, "content", "")
        if not isinstance(raw_text, str):
            raw_text = str(raw_text)

        messages = messages + [
            AIMessage(content=raw_text or "(空)"),
            HumanMessage(
                content=(
                    "你上面的输出不符合要求，错误是：\n"
                    f"{str(out['parsing_error'])[:600]}\n\n"
                    "请只重新输出一个合法的 JSON 对象，字段严格按约定，"
                    "不要解释，不要 markdown 代码块。"
                )
            ),
        ]
        out = chain.invoke(messages)
        if out["parsed"] is not None:
            return out["parsed"]

    raise LLMFormatError(f"结构化输出连续失败：{out['parsing_error']}")
