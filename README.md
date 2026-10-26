# 校园轻活动 AI DIY 工坊

面向学生社团、班团组织的 AI 辅助移动端 Web 活动页面制作与发布工具。

## 项目结构

```text
apps/web/   Next.js 前端
outputs/    团队综合开发文档、OpenAPI、SQL 和环境变量模板
```

## 文档入口

- [团队综合开发文档](./outputs/团队综合开发文档.md)
- [OpenAPI 契约](./outputs/api/openapi.yaml)
- [PostgreSQL 初始化 SQL](./outputs/sql/001_init.sql)
- [环境变量模板](./outputs/.env.example)

## 当前进度

前端第一步：初始化 Next.js App Router 工程骨架，建立首页、项目工作台和公开活动页的占位路由。

## 本地运行

```bash
cd apps/web
pnpm install
pnpm dev
```
