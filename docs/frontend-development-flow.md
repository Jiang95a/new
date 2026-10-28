# 前端开发流程

## 1. 本轮目标

第一步先统一开发环境、工程命令和协作方式，保证每位前端成员拉取代码后都能启动同一套项目。

完成标准：

- VSCode 推荐插件和保存时自动格式化已配置。
- Node.js、pnpm、Git 版本明确。
- 开发、类型检查、格式检查和构建命令统一。
- 前后端目录和文档入口清楚。
- 每次提交使用中文 commit message。

## 2. 工具准备

### 必需

| 工具 | 要求 |
|---|---|
| Node.js | 22.18 或更高，推荐 24 |
| pnpm | 10 或更高 |
| Git | 最新稳定版 |
| VSCode | 最新稳定版 |
| 浏览器 | Chrome 或 Edge 最新版 |

VSCode 打开整个仓库根目录，不要只打开 `apps/web`，这样 Git、文档和 Python 服务可以一起查看。

项目固定使用 `pnpm@11.19.0`。如果终端提示 `pnpm` 不是可识别的命令，先在 PowerShell 执行：

```powershell
corepack enable
corepack prepare pnpm@11.19.0 --activate
pnpm --version
```

如果 Corepack 不可用，再执行：

```powershell
npm install -g pnpm@11.19.0
```

安装后关闭并重新打开终端，再回到 `apps/web` 执行 `pnpm install`。

### 推荐插件

VSCode 会根据 `.vscode/extensions.json` 提示安装：

- ESLint
- Prettier
- Tailwind CSS IntelliSense
- GitLens

保存文件时会自动使用 Prettier 格式化。

## 3. 第一次启动

```bash
cd apps/web
corepack pnpm install
corepack pnpm dev
```

浏览器访问 `http://localhost:5173`。

VSCode 也可以通过 `Terminal -> Run Task` 运行：

- 前端: 安装依赖
- 前端: 启动开发服务器
- 前端: 类型检查
- 前端: 格式检查
- 前端: 构建

快捷键：

- `Ctrl + Shift + B`：执行默认构建任务。
- `F5`：启动 Vue/Vite 调试配置。

## 4. 每日开发流程

```text
拉取最新 main
  -> 创建功能分支
  -> 本地开发
  -> 格式检查和类型检查
  -> 中文提交
  -> 推送分支
  -> 合并到 main
```

### 开始工作

```bash
git pull --rebase origin main
git switch -c feat/页面或功能名
```

### 提交前检查

```bash
cd apps/web
pnpm format:check
pnpm typecheck
pnpm build
```

当前沙箱环境可能无法启动 Vite 子进程，构建以本机终端结果为准。

### 中文提交格式

```text
类型(模块): 中文说明
```

示例：

```text
feat(前端): 完成项目工作台布局
feat(前端): 增加活动页面组件渲染器
fix(前端): 修复手机端表单按钮遮挡
docs: 更新前端开发流程
chore: 更新前端依赖
```

## 5. 前端迭代顺序

### 第一步：工程与协作基线

产出：

- VSCode 配置
- Prettier 配置
- 统一开发命令
- 前端流程文档

### 第二步：设计变量与应用外壳

产出：

- 颜色、间距、字体和圆角变量
- 电脑端工作台布局
- 移动端公共页外壳
- 顶部导航、侧栏和通用反馈组件

### 第三步：PageDocument 渲染器

优先实现：

- `text`
- `button`
- `image`
- `form`
- `success_panel`

要求编辑画布、预览页和公共活动页共用渲染器。

### 第四步：移动端活动页

产出：

- 多页面切换
- 活动信息展示
- 表单填写和提交
- 成功页面
- 开放、截止、满额和下线状态

### 第五步：电脑端工作台与编辑器

产出：

- 项目列表
- 新建项目
- 三栏编辑器
- 组件选择、拖拽排序和属性修改
- 自动保存与 revision 冲突提示

### 第六步：接口接入

产出：

- API Client
- JWT 登录与刷新
- 项目、草稿、版本和发布接口
- 表单提交和数据列表

### 第七步：AI 交互

产出：

- 海报上传与解析结果确认
- 一句话生成进度
- AI Proposal 预览
- 采纳、拒绝和撤销
- 质量检查

### 第八步：测试与比赛演示

产出：

- 电脑端 1440px E2E
- 手机端 390px E2E
- 固定演示账号和数据
- 三分钟演示脚本

## 6. 目录职责

```text
apps/web/
├── src/views/WorkshopView.vue        编辑器主页面
├── src/components/editor/           画布、页面、组件库和属性面板
├── src/components/modals/           创建、预览、发布和质量检查
├── src/stores/editor.ts             PageDocument、页面和撤销状态
├── src/types/editor.ts              Doc / PageDocument / Page / Block 类型
├── src/services/                    智能体、质量检查、导出和海报
├── src/data/                        模板和组件目录
├── src/router/                      Vue Router
├── src/assets/main.css              全局样式
└── public/                          静态资源
```

## 7. 当前下一步

实现第二步：

1. 建立设计变量和应用外壳。
2. 创建电脑端工作台布局。
3. 创建移动端公共页预览布局。
4. 为第三步的 PageDocument 渲染器预留入口。

