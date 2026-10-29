"""知识库语料：读 markdown、拆块。

语料放在 `agent/knowledge/`，**不要**放 `agent/data/`——`data/` 在 .gitignore 里
（本地数据库、日志都在那儿），放进去的后果是评委 clone 下来语料是空的，
RAG 直接退化成 0 分。

为什么语料是 markdown 而不是一段 Python 常量：
1. 写内容的人不用碰代码，改完 rebuild 一下就行；
2. git diff 出来能看懂改了什么；
3. 文件头（front-matter）就是元数据，scene 用来做场景过滤。

分块策略：先按 `## 小节` 切，小节太长再按段落窗口切，块之间留 80 字重叠。
重叠是为了不让一个结论被从中间劈开——切断了反而检索不到。
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

DEFAULT_ROOT = Path(__file__).resolve().parents[3] / "knowledge"

_FRONT_MATTER = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
_SECTION = re.compile(r"^##\s+(.+?)\s*$", re.MULTILINE)


@dataclass
class KnowledgeDoc:
    doc_id: str
    title: str
    scene: str
    kind: str
    tags: list[str] = field(default_factory=list)
    sections: list[tuple[str, str]] = field(default_factory=list)


@dataclass
class Chunk:
    doc_id: str
    title: str
    scene: str
    kind: str
    heading: str
    content: str
    index: int

    @property
    def label(self) -> str:
        return f"{self.title} · {self.heading}" if self.heading else self.title


def _parse_front_matter(text: str) -> tuple[dict[str, str], str]:
    """只支持 `key: value` 单行形式，够用了，别为语料写一个 YAML 解析器。"""
    match = _FRONT_MATTER.match(text)
    if not match:
        return {}, text
    meta: dict[str, str] = {}
    for line in match.group(1).splitlines():
        line = line.strip()
        if not line or line.startswith("#") or ":" not in line:
            continue
        key, value = line.split(":", 1)
        meta[key.strip().lower()] = value.strip()
    return meta, text[match.end() :]


def parse_doc(path: Path) -> KnowledgeDoc | None:
    raw = path.read_text(encoding="utf-8")
    meta, body = _parse_front_matter(raw)

    # 没有 front-matter 的正文按第一个一级标题当文档名
    title = meta.get("title") or path.stem
    scene = (meta.get("scene") or "common").strip().lower()
    kind = (meta.get("kind") or "guide").strip().lower()
    tags = [t.strip() for t in (meta.get("tags") or "").split(",") if t.strip()]

    sections: list[tuple[str, str]] = []
    marks = list(_SECTION.finditer(body))
    if not marks:
        text = body.strip()
        if text:
            sections.append(("", text))
    else:
        head = body[: marks[0].start()].strip()
        if head:
            sections.append(("概述", head))
        for i, mark in enumerate(marks):
            heading = mark.group(1).strip()
            start = mark.end()
            end = marks[i + 1].start() if i + 1 < len(marks) else len(body)
            content = body[start:end].strip()
            if content:
                sections.append((heading, content))

    if not sections:
        return None
    return KnowledgeDoc(
        doc_id=path.stem,
        title=title,
        scene=scene,
        kind=kind,
        tags=tags,
        sections=sections,
    )


def load_docs(root: Path | None = None) -> list[KnowledgeDoc]:
    base = root or DEFAULT_ROOT
    if not base.exists():
        return []
    docs: list[KnowledgeDoc] = []
    for path in sorted(base.glob("*.md")):
        doc = parse_doc(path)
        if doc:
            docs.append(doc)
    return docs


def _split_long(text: str, max_chars: int) -> list[str]:
    """长小节按行窗口切，块间留 overlap 字重叠。"""
    if len(text) <= max_chars:
        return [text]
    overlap = 80
    lines = text.splitlines(keepends=True)
    pieces: list[str] = []
    buf = ""
    for line in lines:
        if len(buf) + len(line) > max_chars and buf:
            pieces.append(buf.strip())
            buf = buf[-overlap:] if len(buf) > overlap else buf
        buf += line
    if buf.strip():
        pieces.append(buf.strip())
    return [p for p in pieces if p]


def chunk_docs(docs: list[KnowledgeDoc], max_chars: int = 520) -> list[Chunk]:
    chunks: list[Chunk] = []
    for doc in docs:
        idx = 0
        for heading, content in doc.sections:
            for piece in _split_long(content, max_chars):
                chunks.append(
                    Chunk(
                        doc_id=doc.doc_id,
                        title=doc.title,
                        scene=doc.scene,
                        kind=doc.kind,
                        heading=heading,
                        content=piece,
                        index=idx,
                    )
                )
                idx += 1
    return chunks


def load_chunks(root: Path | None = None) -> list[Chunk]:
    return chunk_docs(load_docs(root))
