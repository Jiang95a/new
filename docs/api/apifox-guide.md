# 用 Apifox 验证接口：操作手册

> 适用文件：`docs/api/openapi.yaml`（OpenAPI **3.1.0**，25 个 path，29 个 schema）
> 后端需先启动：`java -jar server-0.1.0.jar`，监听 **8080**，context path **`/api/v1`**
> 健康检查：`GET http://127.0.0.1:8080/api/v1/health`

---

## 一、导入（3 步）

1. 打开 Apifox → 左上角 **「+」** → **「导入」** → **「OpenAPI / Swagger」**
2. **「文件导入」** 选择 `D:\Desktop\new\new\docs\api\openapi.yaml`
3. **「导入模式：智能合并」**，目标项目选你自己的项目 → 点「确定」

> 导入后左侧会出现 9 个分组：Auth / Templates / Projects / Draft / Versions /
> Publishing / Public Activities / Submissions / AI。

**如果导入报错**，把错误信息发我——多半是某一行的 YAML 缩进问题，我改。

---

## 二、导入后必须做的两件事

### 2.1 选对服务器

右上角 **环境选择器** → 选 **「本地后端（Spring Boot，server/）」**
即 `http://127.0.0.1:8080/api/v1`。

> ⚠️ **别选成 `8000` 那个**——那是 Python 智能体服务，没启动；
> 也别选 Production。

### 2.2 配 Bearer Token（全局生效）

绝大多数接口需要登录。在 Apifox 里这样做一次：

1. 先跑 **`POST /auth/register`**（或 `/auth/login`），拿到返回里的 `accessToken`
2. 左栏 **「目录」根节点** → **「Auth」标签页** → 类型选 **`Bearer Token`** → 粘贴 token
3. 这样下面所有接口自动带上 `Authorization: Bearer xxx`

> token 有效期短，**过期返回 401** 时，跑一次 `POST /auth/refresh` 拿新的（refresh 是一次性的，旧的立刻失效）。

---

## 三、验证顺序（按这个顺序跑，前面的产出给后面用）

| 步骤 | 接口 | 期望 | 要记下的返回值 |
|---|---|---|---|
| 1 | `GET /health` | 200，`database.ok = true` | — |
| 2 | `POST /auth/register` | 201 或 200 | `accessToken`、`refreshToken` |
| 3 | `GET /auth/me` | 200 | `id` |
| 4 | `GET /templates` | 200，**7 条** | 随便一个 `templateId` |
| 5 | `POST /projects` | 201/200 | **`projectId`** |
| 6 | `GET /projects` | 200 | 列表里有刚建的 |
| 7 | `GET /projects/{projectId}` | 200 | — |
| 8 | `GET /projects/{projectId}/draft` | 200 | **`revision`**（下面 PATCH 要用） |
| 9 | `PUT /projects/{projectId}/draft` | 200，`revision` +1 | 新 `revision` |
| 10 | `PATCH /projects/{projectId}/draft` | 200 | 传旧 `baseRevision` → **409**（这是对的，证明乐观锁生效） |
| 11 | `POST /projects/{projectId}/publish` | 200 | **`publicSlug`** |
| 12 | `GET /public/activities`（**不带 token**） | 200 | 列表里有刚发布的 |
| 13 | `GET /public/activities/{slug}`（**不带 token**） | 200 | 响应里**不应出现 `draftDocument`** |
| 14 | `POST /public/activities/{slug}/submissions`（**不带 token**） | 200 | `submissionId`；再发一次同样的 `idempotencyKey` → 返回**同一个** id |
| 15 | `GET /projects/{projectId}/submissions` | 200 | 有 1 条 |
| 16 | `GET /projects/{projectId}/analytics/summary` | 200 | `byDay`、`byEventType` 非空 |
| 17 | `GET /projects/{projectId}/analytics/events` | 200 | 分页结构 |
| 18 | `POST /assets`（上传一张小图） | 200 | `url` **必须是 `http://` 开头的绝对地址** |
| 19 | 用上一步的 `url` 直接浏览器打开 | 200，能看到图 | — |
| 20 | `POST /projects/{projectId}/duplicate` | 200 | 新 `projectId` |
| 21 | `DELETE /projects/{projectId}` | 200 | 再 `GET` → 404 |

> **第 12/13/14 步必须清掉 Auth 头再跑**，否则测不出「匿名可访问」。
> Apifox 里可以在该接口的 **「Auth → 继承父级 → 改为 No Auth」**。

---

## 四、重点检查项（这几条最容易被忽略）

### 4.1 封面字段

`POST /projects` 响应里应有 4 个字段：
`activityType`、`coverTone`、`coverCode`、`coverTitle`。
**不传这 4 个字段也应该有值**（后端按模板推导）。

### 4.2 公开活动列表不泄露草稿

`GET /public/activities` 返回的每一项**只能有**：
`slug, title, description, activityType, coverTone, coverCode, coverTitle, status, updatedAt`
**绝对不能有** `draftDocument`、`ownerId`。

### 4.3 PATCH 草稿的数组合并

只传一个页面的名字，其它字段不能被清空：

```json
{ "baseRevision": 1, "patch": { "pages": [ { "id": "pg-xxx", "name": "换个名字" } ] } }
```

跑完再 `GET /draft`，确认 **`blocks` 数量没变**。

### 4.4 幂等提交

`POST .../submissions` 连发两次，`idempotencyKey` 保持一致 → **`submissionId` 必须相同**。

### 4.5 文件绝对 URL

`POST /assets` 返回的 `url` 必须是 `http://127.0.0.1:8080/...` 开头，
不能是 `/api/v1/files/...` 这种相对路径（相对路径在前端端口 5173 下会 404）。

---

## 五、常见报错对照

| 现象 | 原因 | 处理 |
|---|---|---|
| `401 UNAUTHORIZED` | 没配 token / token 过期 | 配 Bearer 或跑 `/auth/refresh` |
| `403 FORBIDDEN` | 用 A 用户的 token 访问 B 用户的项目 | 换回创建者 token |
| `409 REVISION_CONFLICT` | `baseRevision` 和服务器不一致 | **这是正确行为**，重新 GET 拿最新 revision |
| `422 PAGE_DOCUMENT_INVALID` | 文档结构不合 schema | 检查 `title`、`pages[].id`、`pages[].blocks` 是否齐 |
| `503 AGENT_UNAVAILABLE` | Python 智能体没启动 | 预期行为，`/ai/*` 接口会降级 |
| `Connection refused` | 8080 没起 | 先启动后端 jar |
| 中文变乱码 | Apifox 显示编码 | 后端统一 UTF-8，改 Apifox 响应编码设置 |

---

## 六、验证完成后

把下面这些结果发我，我据此修 `openapi.yaml` 里剩下对不上的地方：

1. 导入有没有报错（有就把报错贴出来）
2. 第 1~21 步里**哪几步红了**，响应体是什么
3. `POST /projects` 的完整响应（用来核对 `Project` schema 字段）
4. `GET /public/activities` 的完整响应（用来核对 `PublicActivitySummary`）
