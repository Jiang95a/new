"""RAG 测试：语料能读、分块带场景、重建幂等、检索打得准。

这几个断言不是走形式——它们就是「RAG 有没有真的生效」的唯一证据。
以后改语料、改权重，跑一遍就知道有没有把效果改坏。
"""

from __future__ import annotations

import pytest

from app.services.rag import retriever, store
from app.services.rag.corpus import load_chunks, load_docs


@pytest.fixture(scope="module", autouse=True)
def _build_kb():
    store.rebuild()
    yield
    store.invalidate()


def test_corpus_loads_all_docs():
    docs = load_docs()
    assert len(docs) >= 8, f"语料只有 {len(docs)} 个文档，是不是 data/knowledge 丢了"
    for doc in docs:
        assert doc.title
        assert doc.sections, f"{doc.doc_id} 没有解析出任何小节"


def test_chunks_carry_scene_and_heading():
    chunks = load_chunks()
    assert len(chunks) >= 30
    scenes = {c.scene for c in chunks}
    assert {"recruit", "signup", "vote", "checkin", "common"} <= scenes
    assert all(c.heading for c in chunks), "有小节没解析出标题，引用时就没法说清来自哪一份"


def test_rebuild_is_idempotent():
    first = store.rebuild()
    second = store.rebuild()
    assert first["chunks"] == second["chunks"]
    assert second["inserted"] == 0, "重复重建不应该重复插入"
    assert store.stats()["chunks"] == first["chunks"]


def test_recruit_query_hits_recruit_playbook():
    hits = retriever.search("招新表单要收哪些字段")
    assert hits, "招新相关问题一条都没召回"
    assert hits[0].chunk.scene == "recruit"
    assert "招新" in hits[0].chunk.title


def test_copywriting_query_hits_length_rules():
    hits = retriever.search("正文一行最多多少字")
    assert hits
    joined = "".join(h.chunk.heading for h in hits)
    assert "长度" in joined, f"应该命中文案规范的长度约束，实际命中：{joined}"


def test_vote_query_hits_vote_rules():
    hits = retriever.search("投票规则要写清什么")
    assert hits
    assert "投票" in hits[0].chunk.title


def test_scene_detection():
    assert retriever.detect_scene("帮我做个社团招新页") == "recruit"
    assert retriever.detect_scene("校园歌手大赛投票") == "vote"
    assert retriever.detect_scene("21 天阅读打卡") == "checkin"
    assert retriever.detect_scene("讲座报名") == "signup"
    assert retriever.detect_scene("随便说点什么") == ""


def test_empty_query_returns_nothing():
    assert retriever.search("") == []
    assert retriever.search("   ") == []


def test_unrelated_query_below_threshold():
    hits = retriever.search("zzzqqqxxx 完全无关的内容")
    assert hits == [], "无关问题不应该硬凑资料喂给模型"


def test_build_context_has_citations_and_limit():
    text, hits = retriever.build_context("报名截止时间")
    assert hits
    assert "[资料1]" in text
    assert len(text) <= 2000


def test_search_as_text_without_hit_is_honest():
    out = retriever.search_as_text("zzzqqqxxx")
    assert "没有" in out and "不要编造" in out


def test_knowledge_message_is_injectable():
    text, hits = retriever.knowledge_message("表单必填项最多几个")
    assert hits
    assert "参考资料" in text
    assert "待补充" in text, "注入的资料必须带上「不许推测」的约束"
