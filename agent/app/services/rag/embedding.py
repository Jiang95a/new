"""向量化：默认本地哈希向量，可选接 API embedding。

为什么默认不用 API embedding：
1. 评委看代码时，`EMBEDDING_BACKEND=local` 的整条链路是**离线可跑、可复现**的，
   不需要现场有网、有余额；
2. 语料只有几十块，本地哈希向量的召回完全够用；
3. 真要换成 text-embedding-3 或 qwen 的 embedding，只要改一个环境变量。

哈希向量的原理（答辩要能讲）：把中文按字/双字/三字切出来，对每个词做 blake2b
哈希落到固定维度桶里，计数后做 1+log(tf) 压缩再 L2 归一化。
它捕捉的是「词面重叠」，不是「语义相似」——所以我们后面还会混一路 BM25，
并且用场景标签做加权，把纯词面检索的短板补上。
"""

from __future__ import annotations

import hashlib
import math
import re
from typing import Iterable

import httpx

from app.core.config import get_settings

# 分词/向量算法的版本号。改了 tokenize 或 hash_embed 就要 +1，
# 它会参与块的指纹计算，从而让旧向量自动作废、下次 rebuild 重算。
EMBED_VERSION = "v2"

_ASCII_WORD = re.compile(r"[a-z0-9_]+")
_HAN_RUN = re.compile(r"[\u4e00-\u9fff]+")


class EmbeddingError(RuntimeError):
    """向量化失败。检索层要能继续跑（退回词面匹配），不能把整条链路带崩。"""


def tokenize(text: str) -> list[str]:
    """统一分词：英文按词，中文按双字 + 三字。

    为什么中文**不用单字**：单字太散（「的」「了」「内」满天飞），
    一句"完全无关的内容"能靠单字命中一堆文档，把无关问题硬凑出资料。
    双字覆盖面最广，三字能抓住"报名表""信息卡"这类术语，两者足够。
    """
    if not text:
        return []
    lowered = text.lower()
    tokens: list[str] = _ASCII_WORD.findall(lowered)
    for run in _HAN_RUN.findall(lowered):
        tokens.extend(run[i : i + 2] for i in range(len(run) - 1))
        tokens.extend(run[i : i + 3] for i in range(len(run) - 2))
    return tokens


def _bucket(token: str, dim: int) -> int:
    """用 blake2b 而不是内置 hash()：后者每个进程加盐，重启后向量就变了。"""
    digest = hashlib.blake2b(token.encode("utf-8"), digest_size=8).digest()
    return int.from_bytes(digest, "big") % dim


def hash_embed(text: str, dim: int | None = None) -> list[float]:
    """本地哈希向量。同样输入永远得到同样输出，这是能写进测试的前提。"""
    settings = get_settings()
    size = max(64, dim or settings.embedding_dim)
    vec = [0.0] * size
    for token in tokenize(text):
        vec[_bucket(token, size)] += 1.0

    vec = [1.0 + math.log(v) if v > 0 else 0.0 for v in vec]

    norm = math.sqrt(sum(v * v for v in vec))
    if norm <= 0:
        return vec
    return [round(v / norm, 5) for v in vec]


def cosine(a: Iterable[float], b: Iterable[float]) -> float:
    va, vb = list(a), list(b)
    if not va or len(va) != len(vb):
        return 0.0
    return sum(x * y for x, y in zip(va, vb))


def embed_texts(texts: list[str]) -> list[list[float]]:
    """按配置走本地或 API。失败时抛 EmbeddingError，由调用方决定降级方式。"""
    settings = get_settings()
    if not texts:
        return []
    if settings.embedding_backend == "local":
        return [hash_embed(t) for t in texts]
    return _embed_via_api(texts)


def _embed_via_api(texts: list[str]) -> list[list[float]]:
    settings = get_settings()
    if not settings.llm_api_key:
        raise EmbeddingError("EMBEDDING_BACKEND=api 但没有配置 LLM_API_KEY")

    model = settings.embedding_model.strip() or _default_embedding_model(settings.llm_provider)
    url = f"{settings.base_url.rstrip('/')}/embeddings"
    try:
        response = httpx.post(
            url,
            headers={
                "Authorization": f"Bearer {settings.llm_api_key}",
                "Content-Type": "application/json",
            },
            json={"model": model, "input": texts},
            timeout=30.0,
        )
        response.raise_for_status()
        payload = response.json()
        data = payload.get("data") or []
        vectors = [item.get("embedding") for item in sorted(data, key=lambda x: x.get("index", 0))]
        if len(vectors) != len(texts) or any(not isinstance(v, list) for v in vectors):
            raise EmbeddingError("embedding 接口返回的结构不对")
        return [[float(x) for x in v] for v in vectors]
    except httpx.HTTPError as exc:
        raise EmbeddingError(f"embedding 接口调用失败：{exc}") from exc


def _default_embedding_model(provider: str) -> str:
    return {
        "openai": "text-embedding-3-small",
        "qwen": "text-embedding-v3",
        "zhipu": "embedding-3",
        "deepseek": "text-embedding-v3",
    }.get(provider, "text-embedding-3-small")
