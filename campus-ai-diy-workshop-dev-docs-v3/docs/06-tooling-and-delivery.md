# 开发工具、环境与交付计划

## 1. 必选工具

### 通用

| 工具 | 用途 |
|---|---|
| Git + GitHub/GitLab | 版本管理和代码协作 |
| Docker Desktop / Docker Engine | 本地统一运行数据库、Redis、MinIO |
| VS Code 或 JetBrains IDE | 开发 |
| Postman / Insomnia / Bruno | 接口调试 |
| Figma | 页面与组件设计 |

### 前端

| 工具 | 用途 |
|---|---|
| Node.js LTS + pnpm | 前端运行时和依赖管理 |
| Next.js + React + TypeScript | Web 应用 |
| Tailwind CSS + Radix/shadcn | UI 和样式 |
| Zustand | 编辑器局部状态 |
| TanStack Query | 服务端状态与缓存 |
| dnd-kit | 组件拖拽排序 |
| React Hook Form + Zod | 表单和前端校验 |
| qrcode | 生成报名二维码 |
| html-to-image 或 satori | 生成分享海报 |
| Vitest + React Testing Library | 单元和组件测试 |
| Playwright | 端到端测试 |
| ESLint + Prettier | 代码质量与格式 |

### 后端

| 工具 | 用途 |
|---|---|
| Python 3.12+ | 后端运行时 |
| uv 或 Poetry | Python 依赖管理 |
| FastAPI + Pydantic v2 | API 和 Schema |
| SQLAlchemy 2 + Alembic | ORM 与迁移 |
| PostgreSQL 16 | 主数据库 |
| Redis 7 | 限流、缓存、队列 |
| RQ 或 Celery | AI、导出等异步任务 |
| MinIO / S3 SDK | 文件存储 |
| pytest | 后端测试 |
| Ruff | 格式与静态检查 |
| mypy | 类型检查 |

### AI

| 工具 | 用途 |
|---|---|
| 支持结构化输出和图片输入的多模态模型 | 生成页面、解析海报 |
| OpenAI 兼容或多供应商 SDK | 模型调用 |
| JSON Schema 校验器 | 校验模型结果 |
| 提示词模板文件 | 版本化管理提示词 |

V1 至少准备一个备用模型或关闭 AI 时的降级流程。

## 2. 本地环境

建议通过 Docker Compose 启动：

```text
web       Next.js        :3000
api       FastAPI        :8000
worker    RQ/Celery      无公开端口
postgres  PostgreSQL 16  :5432
redis     Redis 7        :6379
minio     MinIO          :9000 / 控制台 9001
```

浏览器访问：

```text
编辑器：http://localhost:3000
API 文档：http://localhost:8000/docs
MinIO 控制台：http://localhost:9001
```

## 3. 环境变量

变量清单可参考 [`outputs/.env.example`](../.env.example)。至少包括：

```dotenv
DATABASE_URL=postgresql+asyncpg://app:app@postgres:5432/campus_diy
REDIS_URL=redis://redis:6379/0
JWT_SECRET=replace-with-at-least-32-random-bytes
JWT_ACCESS_TTL_MINUTES=15
JWT_REFRESH_TTL_DAYS=7

S3_ENDPOINT=http://minio:9000
S3_ACCESS_KEY=minio
S3_SECRET_KEY=replace-me
S3_BUCKET=campus-assets
S3_REGION=local

LLM_PROVIDER=openai-compatible
LLM_API_KEY=replace-me
LLM_BASE_URL=http://host.docker.internal:11434/v1
LLM_MODEL=replace-me
VISION_MODEL=replace-me

PUBLIC_APP_URL=http://localhost:3000
API_BASE_URL=http://localhost:8000/api/v1
AI_MAX_CONCURRENCY_PER_USER=1
UPLOAD_MAX_MB=10
```

规则：

- 不在 Git 中提交真实密钥。
- 生产密钥使用部署平台 Secret。
- 客户端只能读取 `NEXT_PUBLIC_*` 变量，不能包含模型或数据库密钥。
- 上线前更换全部示例密钥。

## 4. 项目初始化顺序

1. 建立 Monorepo 或前后端两个仓库。
2. 定义 PageDocument JSON Schema。
3. 建立组件白名单和属性 Schema。
4. 实现一个 `button`、一个 `text` 和一个 `form` 的最小渲染闭环。
5. 创建 PostgreSQL 和迁移。
6. 跑通注册、登录、创建项目和草稿保存。
7. 实现三栏编辑器和自动保存。
8. 接入模板和手机公共页。
9. 实现表单提交、列表和导出。
10. 接入 AI Job、Proposal、校验和确认应用。
11. 完成海报解析和二维码分享海报。
12. 做端到端测试、真实社团试用和答辩演示。

不要先做聊天界面再想页面协议，否则 AI、编辑器、渲染器会各自形成不同数据结构。

## 5. 四周交付计划

### 第 1 周：基础骨架与编辑闭环

- 产品原型与组件设计
- PageDocument Schema
- 登录、项目和模板
- 基础渲染器
- 三栏编辑器骨架
- 组件添加、删除、属性修改、拖拽和 undo/redo

里程碑：能从模板创建并在编辑器中修改、保存、预览一个页面。

### 第 2 周：发布与表单闭环

- 页面版本和发布快照
- 公共活动页
- 表单字段和提交校验
- 报名截止和人数上限
- 提交列表、CSV 导出
- 二维码

里程碑：能发布活动，用手机提交，在后台查看数据。

### 第 3 周：AI 与海报解析

- AI Job
- 一句话生成 PageDocument
- 海报信息提取和人工确认
- 组件建议 Proposal
- 发布前质量检查
- AI 失败降级

里程碑：完成“海报 -> 页面 -> 建议 -> 采纳”的核心演示链路。

### 第 4 周：完整度与比赛交付

- 分享海报
- 移动端和浏览器兼容
- 安全、限流和错误处理
- 3 个社团试用
- E2E 测试与性能检查
- 演示账号、演示数据和答辩材料

## 6. 团队分工建议

| 角色 | 主要职责 |
|---|---|
| 前端 A | 编辑器、拖拽、状态和组件库 |
| 前端 B | 公共活动页、表单、数据后台和视觉 |
| 后端 | 认证、项目、版本、发布、提交、导出 |
| AI/全栈 | PageDocument、Agent、Proposal、校验、模型接入 |
| 产品/设计 | 模板、交互、测试、答辩和用户试用 |

四个人以上时可以前后端并行。两个人团队则优先砍掉分享海报、AI 质检和复杂动画，但必须保留编辑、发布和提交闭环。

## 7. 演示环境

准备：

- 1 个稳定演示账号
- 1 个“摄影社招新”完整项目
- 1 个可公开访问的手机提交链接
- 1 张真实活动海报
- 20～30 条演示提交记录
- 1 个最终分享海报
- AI 服务的本地或云上备用方案

答辩演示不依赖现场上传大文件或当场等待长时间模型调用。提前完成一版生成，再现场展示局部编辑和提交。

## 8. 版本与验收

建议打三个里程碑 Tag：

```text
v0.1-editor
v0.2-publish
v1.0-demo
```

发布比赛版本前冻结 Schema。最后一周只允许修 bug、文案和视觉，不新增核心组件类型。

