# new

传智杯 B 组 AI Web 网页项目。

## 项目结构

```text
apps/web/    Next.js 前端：电脑端工作台与移动端公开活动页
agent_first/ FastAPI 智能体服务
outputs/     团队综合开发文档、OpenAPI、SQL 和环境变量模板
```

## 文档入口

- [前端开发流程](./docs/frontend-development-flow.md)
- [团队综合开发文档](./outputs/团队综合开发文档.md)
- [OpenAPI 契约](./outputs/api/openapi.yaml)
- [PostgreSQL 初始化 SQL](./outputs/sql/001_init.sql)
- [环境变量模板](./outputs/.env.example)

## 当前进度

- 前端第一步：Next.js App Router 工程骨架，包含首页、项目工作台和公开活动页占位路由。
- 智能体第一步：完成 FastAPI 智能体基础目录、聊天路由、服务层、记忆和工具模块的初始结构。

## 前端本地运行

```bash
cd apps/web
pnpm install
pnpm dev
```
