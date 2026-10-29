# new — 传智杯 B 组 AI Web 网页项目

校园轻活动 AI DIY 工坊：一句话需求或一张海报，生成能报名、能分享、能统计的移动端活动页面。

## 目录

| 目录 | 是什么 | 技术栈 | 端口 |
|---|---|---|---|
| `web/` | 前端编辑器（多页面 PageDocument 编辑与实时预览） | Vue 3 + Vite + TypeScript + Pinia | 5173 |
| `server/` | 后端 API（待搭建） | 待定 + **MySQL 8** | 8080 |
| `agent/` | 智能体服务 | FastAPI + LangChain / LangGraph | 8000 |

`docs/` 是三边共用的资料，不是谁的私有目录：

- [`团队综合开发文档`](./docs/团队综合开发文档.md) — 总体方案
- [`OpenAPI 契约`](./docs/api/openapi.yaml) — **改接口先改它**
- [`MySQL 建库脚本`](./docs/sql/00_create_database.sql) — 建库 + 建专用账号（root 执行）
- [`初始化 SQL（MySQL 8）`](./docs/sql/001_init.sql) — 11 张表，可重复执行
- [`演示数据`](./docs/sql/002_seed.sql) — 演示用户 / 模板 / 项目，后端第一天就能跑通
- [`MySQL 五步上手`](./docs/mysql-快速开始.md) — 装到验证，十分钟
- [`环境变量模板`](./docs/.env.example) — 复制成本地 `.env`
- [`前端开发流程`](./docs/frontend-development-flow.md)
- `docs/finish-step1.ps1` — 第一步环境脚本（历史脚本，备查）

## 本地启动

顺序：**agent → server → web**（前端最依赖别人，最后起，报错最清楚）。

### 1. 智能体

```powershell
cd agent
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
copy .env.example .env          # 填 LLM_API_KEY
.\start.ps1
```

自检（不花钱，验证环境是否就绪）：

```powershell
python selftest.py            # 只看环境、数据库、工具、图
python selftest.py --live     # 额外真调一次模型（几厘钱）
```

文档地址 <http://127.0.0.1:8000/docs>

### 2. 后端

```powershell
cd server        # 目录已建，内容待补（见 server/README.md）
```

### 3. 前端

```powershell
cd web
corepack pnpm install
corepack pnpm dev
```

需要 Node `^22.18.0` 或 `>=24.12.0`，包管理器用 **pnpm**（版本见 `web/package.json` 的 `packageManager` 字段）。

## 当前进度

- 前端已迁移为 Vue 3 + Vite + TypeScript + Pinia。
- 编辑器支持多页面 PageDocument、13 类受控组件、属性修改、实时画布预览、撤销重做、本地保存、发布二维码和静态页导出。
- 智能体：对话 + 工具调用（9 个，含出方案/校验方案）+ **RAG 知识库检索** + **海报多模态解析** + **MCP（stdio/HTTP）** + **AI 护栏与审计**。
  - 离线自检 8/8，单元测试 98 条全过；deepseek 出方案、qwen3.8-max 读海报都实测过。
  - 新增接口：`POST /poster/extract`、`POST /kb/search`、`GET /kb/stats`、`POST /kb/rebuild`、`GET /mcp/manifest`、`POST /mcp/rpc`、`GET /audit/logs`。详见 [`agent/README.md`](./agent/README.md)。
- 前端已接上：创建弹窗的「上传海报」会真调视觉模型预填字段（认不出的留空，不编），AI 面板会显示本轮带了几条资料、调了什么工具。
- 后端：未开始。

## 约定

1. **只改自己的目录。** 跨目录改动先在群里说一声。
2. **密钥只放各自的 `.env`**（已被 `.gitignore` 忽略），绝不提交、绝不截图外发。
3. **接口契约以 `docs/api/openapi.yaml` 为准。** 改了就当天通知三边，当天联调。
4. **提交前 `git status`**，看见 `.env` / `.venv` / `node_modules` / `*.db` 就停手。

## 目录调整说明（2026-10-29）

为便于分工，做了两处改名，历史已用 `git mv` 保留：

- `apps/web/` → `web/`
- `agent_first/` → `agent/`

如果你本地还停留在旧结构，**不要硬 pull 合并**，重新 clone 一份更省事：

```powershell
git clone https://github.com/Jiang95a/new.git new
```
