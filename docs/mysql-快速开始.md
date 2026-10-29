# MySQL 环境：五步跑起来

> 给后端同学。照这个顺序做，**十分钟**能看到表和数据。
> 目录：`docs/sql/`　｜　全量结构：`001_init.sql`（9 张表）

---

## 0. 先确认版本

MySQL **8.0.16 或以上**。低版本会静默忽略 `CHECK` 约束，等于白写。

```powershell
mysql --version
```

看到 `8.0.x` 才继续。`5.7` 请升级——JSON 默认值、CHECK 强制都在 8.0 才有。

---

## 1. 确认服务在跑

```powershell
# 能连上就会直接进 mysql> 提示符
mysql -u root -p
```

连不上（报 2003）说明服务没启动：

```powershell
# 服务名可能是 mysql / MySQL80 / MySQL84，先用这个查
Get-Service | Where-Object { $_.Name -like "*mysql*" }
Start-Service MySQL80
```

---

## 2. 建库 + 建专用账号

```powershell
mysql -u root -p < docs/sql/00_create_database.sql
```

这个脚本做三件事：建 `campus_diy`（utf8mb4）、建 `campus_app` 账号、**只给它这个库的权限**。

> **别用 root 连业务库。** 独立账号是出事时唯一能止损的东西。

密码改成你自己的，但必须满足 MySQL 8 策略：**≥ 8 位，含大小写 + 数字**。

---

## 3. 建表

```powershell
mysql -u campus_app -p campus_diy < docs/sql/001_init.sql
```

脚本用 `IF NOT EXISTS` + 内联索引，**可以重复执行**，不会报错。

---

## 4. 灌演示数据（可选，但强烈建议）

```powershell
mysql -u campus_app -p campus_diy < docs/sql/002_seed.sql
```

给了三样东西：一个演示用户、一个「社团招新」模板、一个已发布状态的演示项目。

**后端同学拿到这个，第一天就能把接口跑通**，不用等别人造数据。

---

## 5. 配 `.env` 并验证

把 `docs/.env.example` 复制成后端的 `.env`，把数据库那几行改成你刚设的：

```ini
DATABASE_URL=mysql+pymysql://campus_app:你的密码@127.0.0.1:3306/campus_diy?charset=utf8mb4
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=campus_diy
DB_USER=campus_app
DB_PASSWORD=你的密码
```

验证三件事：

```sql
-- ① 9 张表都在
SHOW TABLES;

-- ② 字符集必须是 utf8mb4（出现 utf8 或 latin1 就要重建）
SELECT TABLE_NAME, TABLE_COLLATION FROM information_schema.TABLES
 WHERE TABLE_SCHEMA = DATABASE();

-- ③ CHECK 约束真的生效了（8.0.16+ 才会有 30 多条）
SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
 WHERE TABLE_SCHEMA = DATABASE() AND CONSTRAINT_TYPE = 'CHECK';
```

---

## 常见错误

| 报错 | 原因 | 解法 |
|---|---|---|
| `2003 Can't connect to MySQL server` | 服务没起 | `Start-Service MySQL80` |
| `1045 Access denied ... (using password: YES)` | 密码不对；或账号根本没建成（密码太弱，`CREATE USER` 失败了） | `ALTER USER 'campus_app'@'localhost' IDENTIFIED BY '新密码';` |
| `1819 password does not satisfy ...` | 密码太弱 | 换 ≥8 位、含大小写+数字 |
| `1049 Unknown database 'campus_diy'` | 跳过第 2 步 | 重跑 `00_create_database.sql` |
| `1044 Access denied to database` | GRANT 没生效 | 重跑 `GRANT ... ; FLUSH PRIVILEGES;` |
| `1064 syntax error near 'CHECK'` | MySQL < 8.0.16 | 升级 MySQL |
| 中文字段存进去变 `??` | 字符集是 `utf8` 不是 `utf8mb4` | 重建库和表，见上面第 ② |

---

## 四条约定（跟 agent 那边对上，别各走一套）

1. **时间字段统一 `DATETIME`，全库只用一个时区**（全 UTC 或全 +08:00，不能混）。
   `TIMESTAMPTZ` 是 PostgreSQL 的东西，MySQL 没有。
2. **主键是 `CHAR(36)` 的 UUID**（`DEFAULT (UUID())`）。别改成自增——`openapi.yaml` 里写的就是 uuid。
3. **JSON 列不能直接建索引**。要按 JSON 内部字段查，得加生成列 + 索引，或者放 Elasticsearch。
   V1 的页面文档是整存整取，不需要。
4. **`projects.published_version_id` 没有外键**（会和 `page_versions` 形成循环依赖）。
   一致性由后端保证：发布时先写 `page_versions`，再回填这个字段。

---

## 和 agent 那边的关系

AI 服务（`agent/`）**不连你们的业务库**。它只做「JSON 进、JSON 出」。

它自己要存聊天记录，用的是同一个 `DB_BACKEND` 开关（见 `agent/README.md`），
默认 SQLite，需要时切 MySQL——**用另一个库名、另一个账号**，别和业务表混。

接口契约以 `docs/api/openapi.yaml` 为准；AI 服务在 `http://127.0.0.1:8000`。
