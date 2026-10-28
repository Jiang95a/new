"""pytest 夹具：保证任何测试跑之前，数据库和表都已就绪。"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

# 让 pytest 无论从哪个目录启动都能 import app
ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))


@pytest.fixture(scope="session", autouse=True)
def _prepare_db():
    from app.db.base import init_db

    init_db()
    yield
