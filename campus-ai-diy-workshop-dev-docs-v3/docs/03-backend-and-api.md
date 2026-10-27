# 后端服务与接口说明

## 1. 后端职责

FastAPI 服务负责：

- 用户认证与资源授权
- 项目、模板、草稿和版本管理
- 素材上传和签名访问
- AI 异步任务与提案持久化
- 发布快照管理
- 公共活动访问
- 表单提交、统计与导出
- 安全校验、限流和审计

AI 调用不放在前端，模型密钥不能进入浏览器。

## 2. 服务模块

```text
apps/api/app/
├── main.py
├── core/
│   ├── config.py
│   ├── security.py
│   ├── errors.py
│   └── logging.py
├── modules/
│   ├── auth/
│   ├── users/
│   ├── templates/
│   ├── projects/
│   ├── documents/
│   ├── versions/
│   ├── assets/
│   ├── publishing/
│   ├── public_activity/
│   ├── submissions/
│   ├── analytics/
│   └── ai/
├── db/
│   ├── models/
│   ├── repositories/
│   └── session.py
└── workers/
    └── jobs.py
```

## 3. 通用接口规范

### Base URL

```text
开发环境：http://localhost:8000/api/v1
生产环境：https://api.example.com/api/v1
```

### 认证

- 组织者接口使用 Bearer JWT。
- Access Token 建议 15 分钟，Refresh Token 建议 7 天。
- 公共活动和表单提交接口不要求组织者登录。

```http
Authorization: Bearer <access_token>
```

### 响应格式

成功：

```json
{
  "data": {},
  "requestId": "req_01J..."
}
```

分页：

```json
{
  "data": [],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 53
  },
  "requestId": "req_01J..."
}
```

错误：

```json
{
  "error": {
    "code": "REVISION_CONFLICT",
    "message": "页面已被其他编辑更新",
    "details": {
      "currentRevision": 12
    }
  },
  "requestId": "req_01J..."
}
```

### 常用错误码

| HTTP | code | 含义 |
|---|---|---|
| 400 | `INVALID_INPUT` | 输入不合法 |
| 401 | `UNAUTHENTICATED` | 未登录或令牌失效 |
| 403 | `FORBIDDEN` | 无资源权限 |
| 404 | `NOT_FOUND` | 资源不存在 |
| 409 | `REVISION_CONFLICT` | 草稿版本冲突 |
| 409 | `SLUG_CONFLICT` | 公开链接冲突 |
| 413 | `FILE_TOO_LARGE` | 文件超限 |
| 422 | `PAGE_SCHEMA_INVALID` | 页面结构不合法 |
| 429 | `RATE_LIMITED` | 请求过于频繁 |
| 503 | `AI_UNAVAILABLE` | AI 服务暂不可用 |

## 4. 接口目录

### 4.1 认证

| 方法 | 路径 | 说明 |
|---|---|---|
| POST | `/auth/register` | 注册 |
| POST | `/auth/login` | 登录 |
| POST | `/auth/refresh` | 刷新令牌 |
| POST | `/auth/logout` | 注销当前会话 |
| GET | `/auth/me` | 当前用户 |

### 4.2 模板

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/templates` | 模板列表，支持 category |
| GET | `/templates/{templateId}` | 模板详情 |
| POST | `/templates/{templateId}/use` | 基于模板创建项目 |

### 4.3 项目

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/projects` | 项目列表 |
| POST | `/projects` | 创建空白或模板项目 |
| GET | `/projects/{projectId}` | 项目详情 |
| PATCH | `/projects/{projectId}` | 修改标题、描述 |
| DELETE | `/projects/{projectId}` | 软删除项目 |
| POST | `/projects/{projectId}/duplicate` | 复制为新项目 |

创建项目请求：

```json
{
  "title": "摄影社 2026 秋季招新",
  "templateId": "tpl_club_recruitment",
  "initialDocument": null
}
```

### 4.4 页面草稿

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/projects/{projectId}/draft` | 获取草稿和 revision |
| PUT | `/projects/{projectId}/draft` | 覆盖保存整份 PageDocument |
| POST | `/projects/{projectId}/draft/validate` | 校验草稿 |

保存请求：

```json
{
  "baseRevision": 11,
  "document": {
    "schemaVersion": "1.0",
    "title": "摄影社 2026 秋季招新",
    "homePageId": "page_home",
    "theme": {
      "primaryColor": "#2457D6",
      "backgroundColor": "#F6F8FC",
      "textColor": "#172033",
      "radius": 16,
      "fontScale": 1
    },
    "pages": []
  }
}
```

成功响应：

```json
{
  "data": {
    "revision": 12,
    "savedAt": "2026-10-26T12:00:00Z"
  }
}
```

### 4.5 素材

| 方法 | 路径 | 说明 |
|---|---|---|
| POST | `/assets` | 上传海报、页面图片 |
| GET | `/assets/{assetId}` | 获取素材元数据 |
| DELETE | `/assets/{assetId}` | 删除未使用素材 |

上传使用 `multipart/form-data`，参数包括 `file` 和可选 `projectId`。

上传成功后返回内部素材 ID 和临时签名预览 URL。PageDocument 中只保存稳定素材 URL 或 `assetId`，不能保存会过期的签名 URL。

### 4.6 版本与发布

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/projects/{projectId}/versions` | 版本列表 |
| POST | `/projects/{projectId}/versions` | 从当前草稿创建版本 |
| POST | `/projects/{projectId}/versions/{versionId}/restore` | 恢复到草稿 |
| GET | `/projects/{projectId}/publish-settings` | 发布设置 |
| PUT | `/projects/{projectId}/publish-settings` | 修改发布设置 |
| POST | `/projects/{projectId}/publish` | 发布指定版本 |
| POST | `/projects/{projectId}/unpublish` | 下线活动 |

发布请求：

```json
{
  "versionId": "ver_01J...",
  "slug": "photo-club-2026"
}
```

发布操作成功后返回：

```json
{
  "data": {
    "publicSlug": "photo-club-2026",
    "publicUrl": "https://app.example.com/p/photo-club-2026",
    "publishedVersionId": "ver_01J...",
    "publishedAt": "2026-10-26T12:10:00Z"
  }
}
```

### 4.7 公共活动

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/public/activities/{slug}` | 获取已发布活动首页和页面结构 |
| GET | `/public/activities/{slug}/pages/{pageId}` | 获取发布版本中的指定页面 |
| POST | `/public/activities/{slug}/submissions` | 提交表单 |
| GET | `/public/activities/{slug}/status` | 活动开放状态 |

提交请求：

```json
{
  "pageId": "page_form",
  "formComponentId": "cmp_form",
  "answers": {
    "name": "张同学",
    "studentNo": "20260001",
    "department": "media",
    "contact": "13800000000"
  },
  "idempotencyKey": "6c1f2e3d-..."
}
```

后端只接受当前发布版本中存在的字段，并按字段定义执行类型、必填、长度和选项校验。

### 4.8 提交数据

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/projects/{projectId}/submissions` | 提交列表 |
| GET | `/projects/{projectId}/submissions/{submissionId}` | 提交详情 |
| PATCH | `/projects/{projectId}/submissions/{submissionId}` | 标记无效或备注 |
| GET | `/projects/{projectId}/analytics/summary` | 提交统计 |
| POST | `/projects/{projectId}/exports` | 创建 CSV 导出任务 |
| GET | `/exports/{exportId}` | 获取导出结果 |

### 4.9 AI

| 方法 | 路径 | 说明 |
|---|---|---|
| POST | `/ai/jobs` | 创建生成、建议或检查任务 |
| GET | `/ai/jobs/{jobId}` | 查询任务结果 |
| POST | `/ai/proposals/{proposalId}/apply` | 应用提案 |
| POST | `/ai/proposals/{proposalId}/reject` | 拒绝提案 |
| POST | `/ai/proposals/{proposalId}/undo` | 撤销已应用提案 |

创建 Job：

```json
{
  "kind": "generate_from_poster",
  "projectId": "prj_01J...",
  "prompt": "生成摄影社招新活动页",
  "assetIds": ["ast_01J..."],
  "selectedComponentId": null
}
```

`kind` 取值：

- `generate_from_prompt`
- `generate_from_poster`
- `component_suggestions`
- `quality_check`

Job 响应：

```json
{
  "data": {
    "jobId": "job_01J...",
    "status": "queued"
  }
}
```

完成后的结果中返回一个或多个 Proposal。整页生成 Proposal 的 `target` 为页面文档，组件建议 Proposal 的 `target` 为组件或页面。

## 5. 授权规则

- 用户只能访问自己拥有的项目。
- 参与者只能读取发布快照的公共字段。
- 提交只能写入当前发布且开放中的活动。
- 导出和提交列表只允许项目所有者访问。
- 素材删除前检查是否被草稿或发布版本引用。
- 已发布版本不可修改，只能发布新版本或下线。

## 6. 并发与幂等

- 草稿保存使用 `baseRevision` 乐观锁。
- 发布使用事务更新项目和发布版本。
- 表单提交使用 `idempotencyKey`，相同 key 24 小时内返回第一次结果。
- AI Job 创建可接受 `clientRequestId` 防止重复计费。
- CSV 导出通过异步任务生成，避免长请求阻塞。

## 7. 限流建议

| 接口 | 建议 |
|---|---|
| 登录 | IP + 账号双维度限制 |
| AI Job | 每用户并发 1～2 个，日额度可配置 |
| 公共活动访问 | IP 基础限流 |
| 表单提交 | 活动 + IP + 设备指纹限制 |
| 上传 | 用户、文件大小和频率限制 |

## 8. 缓存策略

- 模板列表可缓存 5 分钟。
- 发布活动快照可缓存，发布新版本或下线时主动失效。
- 用户项目和草稿不进入公共 CDN。
- AI 结果不跨用户缓存。

## 9. OpenAPI

可机读的核心接口定义位于 [`api/openapi.yaml`](../api/openapi.yaml)。实现时应先更新契约，再生成或修改前端客户端。

