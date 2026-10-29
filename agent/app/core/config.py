"""全局配置。

规矩：
1. 所有密钥只从环境变量 / .env 读，代码里一个字符都不许出现。
2. 所有可调参数（模型、温度、超时）都在这儿，别散落在业务里。
3. 用 lru_cache 保证整个进程只有一个 Settings 实例。
"""

from __future__ import annotations

from functools import lru_cache
from typing import Literal

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# 各家「兼容 OpenAI 协议」的地址和常用模型。
# 换供应商只要改 .env 里的 LLM_PROVIDER，代码一行不用动。
PROVIDER_PRESETS: dict[str, dict[str, str]] = {
    "deepseek": {"base_url": "https://api.deepseek.com/v1", "model": "deepseek-chat"},
    "openai": {"base_url": "https://api.openai.com/v1", "model": "gpt-4o-mini"},
    "qwen": {
        "base_url": "https://dashscope.aliyuncs.com/compatible-mode/v1",
        "model": "qwen-plus",
    },
    "zhipu": {"base_url": "https://open.bigmodel.cn/api/paas/v4", "model": "glm-4-plus"},
    "custom": {"base_url": "", "model": ""},
}


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
    )

    # ---- 应用 ----
    app_name: str = "campus-agent"
    debug: bool = True

    # ---- 模型 ----
    llm_provider: Literal["deepseek", "openai", "qwen", "zhipu", "custom"] = "deepseek"
    llm_api_key: str = ""
    llm_base_url: str = ""          # 留空则用 PROVIDER_PRESETS
    llm_model: str = ""             # 留空则用 PROVIDER_PRESETS
    llm_temperature: float = 0.3
    llm_timeout: int = 60
    llm_max_tokens: int = 2048

    # ---- 服务 ----
    host: str = "127.0.0.1"
    port: int = 8000
    cors_origins: str = "*"         # 逗号分隔，如 "http://localhost:5173,http://127.0.0.1:3000"
    history_limit: int = 20         # 每次带给模型的历史消息条数上限
    db_path: str = "data/agent.db"

    # ---- 派生属性 ----
    @field_validator("llm_provider", mode="before")
    @classmethod
    def _normalize_provider(cls, v: object) -> str:
        text = str(v or "").strip().lower()
        return text or "deepseek"

    @property
    def base_url(self) -> str:
        return self.llm_base_url.strip() or PROVIDER_PRESETS[self.llm_provider]["base_url"]

    @property
    def model_name(self) -> str:
        return self.llm_model.strip() or PROVIDER_PRESETS[self.llm_provider]["model"]

    @property
    def cors_list(self) -> list[str]:
        items = [x.strip() for x in self.cors_origins.split(",") if x.strip()]
        return items or ["*"]

    @property
    def has_key(self) -> bool:
        return bool(self.llm_api_key.strip())

    def safe_summary(self) -> dict[str, object]:
        """给 /health 用：绝不包含 key 本身，只说有没有。"""
        return {
            "provider": self.llm_provider,
            "model": self.model_name,
            "base_url": self.base_url,
            "key_configured": self.has_key,
            "temperature": self.llm_temperature,
            "history_limit": self.history_limit,
        }


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
