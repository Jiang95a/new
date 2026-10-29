# 智能体服务（agent）

FastAPI + LangChain + LangGraph 的智能体骨架。**固定代码已就位并跑通**，业务逻辑留了钩子。

当前状态：离线自检 5/5，单元测试 9/9。填上 API Key 即可真调模型。

## 启动

```powershell
cd agent
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
copy .env.example .env      # 填 LLM_API_KEY
python selftest.py          # 不花钱，验证环境
.\start.ps1
```

真调一次模型：`python selftest.py --live`

## 接口

| 方法 | 路径 | 说明 |
|---|---|---|
| POST | `/chat` | 一问一答，返回 thread_id / reply / tool_calls / latency_ms |
| POST | `/chat/stream` | 流式（SSE），每行 `data: {"delta": "..."}`，末尾 `data: [DONE]` |
| GET | `/chat/threads` | 最近的会话 id |
| GET | `/chat/{thread_id}/history` | 某个会话的历史 |
| DELETE | `/chat/{thread_id}` | 清空会话 |
| GET | `/health` | 探活（返回模型配置，不含 key） |

错误码：`422` 入参不合法；`502` 模型异常；**`503` 没配 key —— 后端应据此降级到模板创建**。

## 目录

```
agent/
├── app/
│   ├── main.py                 入口：CORS、路由、lifespan
│   ├── core/
│   │   ├── config.py           全部配置，只从 .env 读；供应商预设
│   │   └── prompts.py          系统提示词（← 改产品行为就改这里）
│   ├── routers/chat.py         4 个接口 + 错误码翻译
│   ├── schemas/chat_schema.py  请求/响应模型
│   ├── services/
│   │   ├── llm_client.py       建模型 + 结构化输出兜底重试
│   │   ├── agent_service.py    ★ LangGraph 图 + chat()/stream_chat()
│   │   ├── tools/              工具注册表（加工具来这儿）
│   │   └── memory/             聊天记录存取（SQLite）
│   └── db/base.py              连接、建表、演示数据
├── tests/                      pytest 冒烟测试
├── selftest.py                 命令行自检
└── start.ps1                   启动脚本
```

## 图长什么样

```
START → agent ──(模型请求调用工具)──► tools ──► agent ...
          └────(模型直接回答)────► END
```

工具节点是手写的（没用 `ToolNode`），因为要能解释"工具到底怎么被调用"。
轮次上限 4 轮、递归上限 14 步，防模型自嗨。

## 加一个工具

```python
# app/services/tools/my_tool.py
from langchain_core.tools import tool

@tool
def count_pages(activity_name: str) -> str:
    """统计某个活动有多少页面。输入活动名称。"""
    return f"{activity_name}：4 个页面"
```

然后在 `app/services/tools/__init__.py` 的 `ALL_TOOLS` 里加一行，重启即可。

**规矩**：docstring 是给模型看的说明书；永远返回字符串；永远别抛异常。

## 换模型

改 `.env`，代码不动：

```ini
LLM_PROVIDER=qwen
LLM_API_KEY=sk-你的百炼key
```

预设见 `app/core/config.py` 的 `PROVIDER_PRESETS`（deepseek / openai / qwen / zhipu / custom）。

## 数据库

一套接口，两种后端，靠 `DB_BACKEND` 切换。**代码里只写 `?` 占位符**，方言翻译在 `app/db/base.py`。

| 后端 | 什么时候用 | 说明 |
|---|---|---|
| `sqlite`（默认） | 开发、跑测试 | 零依赖，数据在 `data/agent.db`，删了自动重建 |
| `mysql` | 联调、部署 | 需要 `pip install pymysql`（已写进 requirements） |

切换只需改 `.env` 并重启：

```ini
DB_BACKEND=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=你的密码
DB_NAME=campus_agent
```

三条说明：

1. **库不存在会自动创建**（`CREATE DATABASE IF NOT EXISTS`，utf8mb4）。但账号得有建库权限。
2. **agent 用独立用户、只授权自己的表**，别用业务库的管理员账号——AI 服务是最容易被注入的一环。
3. MySQL 表结构在 `MYSQL_DDL` 里，和 SQLite 那份是分开的两份，不是自动生成的。**改表要改两处**。

连不上时的报错是包装过的人话（`DBError`），不会甩 pymysql 的裸堆栈：

```
连不上 MySQL（127.0.0.1:3306）：(1045, "Access denied ...")。检查服务是否启动、账号密码、以及 DB_BACKEND 是否写对。
```

## 已知边界

1. 没上 checkpointer，所以没有"中断等人确认"。做编辑 Copilot 时再加。
2. 流式不返回 tool_calls 轨迹，只有纯文本。
3. SQLite 单机、并发写会锁；换 MySQL 是为了联调，不是为了高并发。
4. `HISTORY_LIMIT=20` 是硬截断，没做摘要。

## 出问题先跑自检

```powershell
python selftest.py
python -m pytest tests -q
```

| 现象 | 先看哪 |
|---|---|
| 503 AI_NOT_CONFIGURED | `.env` 里 `LLM_API_KEY` 填了没；有没有重启服务 |
| 502 AI_FAILED | 控制台堆栈；大概率是 key 无效或余额不足 |
| `'gbk' codec can't decode` | 终端先执行 `$env:PYTHONUTF8=1` |
| 端口被占 | `netstat -ano | findstr :8000` |
| 模型不调工具 | 工具 docstring 太含糊，模型不知道什么时候用 |
