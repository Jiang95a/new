# 后端服务

Spring Boot 3.4 + MyBatis + MySQL 8 + JWT，默认端口 **8080**，接口前缀
`/api/v1`。

## Windows 快速启动

仓库提供了 `dev.ps1`，会自动寻找 JDK 21 和 Maven，并把依赖缓存放到
`server/.maven-repo`：

```powershell
cd server
.\dev.ps1                 # 启动后端
.\dev.ps1 compile         # 只编译
.\dev.ps1 spring-boot:run # 显式启动
```

如果没有找到 JDK 21 或 Maven，请安装后重新打开终端；也可以分别设置
`JAVA_HOME` 和 `MAVEN_HOME`。

## 数据库

首次使用按顺序执行：

```powershell
mysql -u root -p --default-character-set=utf8mb4 -e "source ../docs/sql/00_create_database.sql"
mysql -u campus_app -p --default-character-set=utf8mb4 campus_diy -e "source ../docs/sql/001_init.sql"
mysql -u campus_app -p --default-character-set=utf8mb4 campus_diy -e "source ../docs/sql/002_seed.sql"
mysql -u campus_app -p --default-character-set=utf8mb4 campus_diy -e "source ../docs/sql/003_cover_fields.sql"
mysql -u campus_app -p --default-character-set=utf8mb4 campus_diy -e "source ../docs/sql/004_more_templates.sql"
```

启动后可访问：

- 健康检查：`GET http://127.0.0.1:8080/api/v1/health`
- 完整验收：`powershell -ExecutionPolicy Bypass -File .\e2e-test.ps1`

## 与其他两端的边界

| 方向 | 约定 |
|---|---|
| web → server | 接口以 `docs/api/openapi.yaml` 为准 |
| server → agent | `POST http://127.0.0.1:8000/chat`，超时给到 90 秒 |
| 数据 | 页面 JSON 由 backend 落库；agent 不连数据库 |

## 两条硬约定

- **AI 服务返回 503 时，后端要降级到"手动创建/模板创建"**，别让用户卡在一个转圈上。（PRD 第 9 节要求）
- **页面文档的版本管理在后端。** agent 只负责生成和修改指令，不负责存历史。
