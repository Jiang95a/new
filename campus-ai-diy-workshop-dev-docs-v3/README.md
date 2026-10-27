# 校园轻活动 AI DIY 工坊：开发资料包

这是一套面向 V1 开发的资料入口，覆盖产品、前端、后端、智能体、数据库、接口、工具和验收要求。

## 团队一页入口

如果只需要把一份文件发给全体成员，请直接使用：

**[《校园轻活动 AI DIY 工坊 V1.0 团队综合开发文档》](./campus-ai-diy-workshop-team-handbook.md)**

该文档已经把双端前端、JWT、后端 API、智能体、数据库与完整 SQL、开发工具、协作计划和验收要求整合在一起。

## 推荐阅读顺序

1. [团队综合开发文档](./campus-ai-diy-workshop-team-handbook.md)
2. [V1.0 产品需求文档](./campus-ai-diy-workshop-v1-prd.md)
3. [系统架构与关键决策](./docs/01-system-architecture.md)
4. [前端产品与技术规格](./docs/02-frontend-spec.md)
5. [后端服务与接口说明](./docs/03-backend-and-api.md)
6. [智能体设计与工具协议](./docs/04-agent-design.md)
7. [数据库设计](./docs/05-database-design.md)
8. [开发工具与环境](./docs/06-tooling-and-delivery.md)
9. [测试、联调与验收](./docs/07-test-and-acceptance.md)
10. [OpenAPI 契约](./api/openapi.yaml)
11. [PostgreSQL 初始化 SQL](./sql/001_init.sql)

## 产品边界

- 交付对象是可公开访问的移动端 Web/H5 活动页，不依赖微信小程序运行时。
- “小程序式组件”指 Web 端的移动 UI 组件，不是微信原生组件。
- V1 只服务社团招新、活动报名、投票评选、每日打卡四类校园场景。
- AI 输出受控的页面结构和操作补丁，不直接生成可执行 HTML/CSS/JavaScript。
- 所有 AI 修改在用户确认前都不能覆盖已保存版本。

## 核心业务闭环

```text
创建项目
  -> 模板 / 一句话 / 活动海报
  -> AI 生成页面草稿
  -> 可视化编辑和 AI 优化
  -> 手机预览
  -> 发布 Web 链接和二维码
  -> 参与者提交
  -> 组织者查看并导出数据
```

## 技术基线

| 层级 | 推荐方案 |
|---|---|
| Web 前端 | Next.js + React + TypeScript |
| 编辑器状态 | Zustand |
| 组件拖拽 | dnd-kit |
| 服务端请求 | TanStack Query |
| UI | Tailwind CSS + Radix/shadcn |
| 后端 | FastAPI + Pydantic |
| 数据库 | PostgreSQL 16 |
| 缓存与任务 | Redis + RQ/Celery |
| 文件存储 | 本地 MinIO，生产使用 S3 兼容存储 |
| 接口协议 | REST + JSON，OpenAPI 3.1 |
| 部署 | Docker Compose；生产 Web/API 分域部署 |

技术方案不是参赛强制项。如果团队更熟悉 Vue/Element Plus 或 Node.js，可以替换实现，但页面 JSON、API 语义和权限边界应保持不变。

## 四个必须先定下来的决策

1. **PageDocument**：一页或多页活动页面的唯一数据协议。
2. **AI Proposal**：AI 返回可校验、可预览、可拒绝和可撤销的操作提案。
3. **Published Snapshot**：发布时冻结版本，参与者看到的内容不会随编辑草稿变化。
4. **一套前端、两套外壳**：电脑端负责组织和编辑，移动端负责活动消费；两端共用 PageDocument 和组件渲染器。

## 目录说明

```text
outputs/
├── campus-ai-diy-workshop-v1-prd.md
├── campus-ai-diy-workshop-team-handbook.md
├── README.md
├── docs/
│   ├── 01-system-architecture.md
│   ├── 02-frontend-spec.md
│   ├── 03-backend-and-api.md
│   ├── 04-agent-design.md
│   ├── 05-database-design.md
│   ├── 06-tooling-and-delivery.md
│   └── 07-test-and-acceptance.md
├── api/
│   └── openapi.yaml
└── sql/
    └── 001_init.sql
```

## V1 完成定义

以下流程在一台手机和一台电脑上均可完整跑通时，V1 才能视为完成：

```text
上传招新海报
  -> 提取活动信息
  -> 生成多页面活动页
  -> 选中按钮获得 AI 优化建议
  -> 一键采纳并撤销
  -> 发布二维码
  -> 手机提交报名
  -> 后台查看并导出报名记录
```

