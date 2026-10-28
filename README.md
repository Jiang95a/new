# new

传智杯 B 组 AI Web 网页项目。

## 项目结构

```text
apps/web/    Vue 3 + Vite 前端：多页面 PageDocument 编辑器与实时预览
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

- 前端已迁移为 Vue 3 + Vite + TypeScript + Pinia。
- 编辑器支持多页面 PageDocument、13 类受控组件、属性修改、实时画布预览、撤销重做、本地保存、发布二维码和静态页导出。
- 智能体第一步：完成 FastAPI 智能体基础目录、聊天路由、服务层、记忆和工具模块的初始结构。

## 前端本地运行

```bash
cd apps/web
corepack pnpm install
corepack pnpm dev
```
