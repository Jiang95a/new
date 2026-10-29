# DIY-campus · 校园轻活动 AI DIY 工坊（前端）

面向社团 / 班团活动负责人的移动端活动页制作工具。当前版本是**纯前端可演示版**：
手动选组件搭页面、AI（或本地规则）一句话生成、可视化编辑、质量检查、手机预览、发布二维码、导出静态页，
整条链路都能跑通，数据全部存在浏览器本地。

## 页面路由

- `/projects`：项目工作台
- `/projects/new`：新建活动
- `/editor/:projectId`：三栏 DIY 编辑器
- `/p/:slug`：移动端公开活动页

项目工作台、新建活动和公开活动页沿用团队原有视觉；编辑器底部复用
PageDocument、组件库、属性面板、AI 建议、预览、二维码和分享海报能力。

## 跑起来

```bash
corepack pnpm install
corepack pnpm dev          # http://localhost:5173
corepack pnpm build        # 类型检查 + 生产构建
corepack pnpm test:unit    # vitest
```

Node 版本按 `package.json` 的 engines：`^22.18 || >=24.12`。

## 这一版做了什么

### 1. 手动选组件建页面

- 13 种受控组件：导航栏、Banner、标题、文本、图片、信息卡片、按钮、表单、单选框、多选框、二维码、分割线、倒计时
- 组件库支持**拖进画布任意位置**，也支持点一下加到末尾
- 画布内拖拽排序、上移 / 下移、复制、隐藏、删除
- 属性面板按组件类型动态生成（`data/blockCatalog.ts` 的 `fieldsFor`），样式面板管主题色 / 圆角 / 字号 / 间距 / 按钮风格
- 多页面：首页 / 内容页 / 表单页 / 成功页，按钮可以跳页、提交、开链接

### 2. AI 生成（没后端也能用）

两条路，前端会自动选：

| 情况                                  | 走哪条                                        | 结果                                      |
| ------------------------------------- | --------------------------------------------- | ----------------------------------------- |
| 智能体在线（`agent/` 起在 8000）      | `POST /chat`，要求它输出结构化 JSON           | 解析成受控组件，标注「智能体」            |
| 智能体没起 / 没配 Key / 输出不是 JSON | 读它的「页面名：组件列表」文本结构            | 解析成受控组件，标注「智能体 · 文本结构」 |
| 以上都失败                            | 本地规则：关键词匹配模板 + 抽取时间/地点/人数 | 标注「本地规则」                          |

本地规则不是玩具：能从「摄影社招新，10月26日晚7点在阶梯教室面试，招60人」里抽出活动名、时间、地点、人数，
填进信息卡片，并按场景（招新 / 报名 / 投票 / 打卡）选模板、配主题色。模板里的日期按「今天 + N 天」算，不会过两天就显示「已截止」。

### 3. 编辑 Copilot 与质量检查

- 选中组件后，AI 面板给出 1~4 条**可执行建议**：每条带原因、修改前后对比，点「应用」才写入，写入后可撤销
- 建议 id 是稳定 key（页面 + 组件 + 标题），重算不会重复冒出来
- 质量检查是纯前端规则引擎（`services/quality.ts`）：表单必填/重复字段/缺联系方式、按钮文案、标题长度、文本长度、
  主色对比度（WCAG）、截止时间格式、空页面、缺成功页、长英文串溢出风险……每条都能「定位」到具体组件

### 4. 预览 / 发布 / 导出

- 预览：390 宽真机尺寸，可切页面、填表单、提交后跳到成功页，必填校验会飘红
- 发布：生成 `#preview=<slug>` 链接 + 二维码（`uqr` 纯前端算，不联网），带「已发布」状态；改内容链接不变
- 分享海报：Canvas 画 750×1000 PNG，含标题、时间/地点/主办、简介、二维码
- 导出：项目 JSON（可再导入）、当前页静态 HTML（复用运行中的样式，双击就能看）

### 5. 编辑器体验

撤销 / 重做（Ctrl+Z / Ctrl+Shift+Z / Ctrl+Y，合并输入，最多 80 步）、自动保存到 localStorage（刷新接着改）、
Ctrl+S 手动保存、Ctrl+D 复制、Delete 删除、Esc 取消选中、设备宽度 375/390/430、缩放自适应、窄屏抽屉面板。

## 目录结构

```
src/
├─ views/WorkshopView.vue          唯一页面：头部 + 左中右三栏 + 状态栏 + 弹窗
├─ components/
│  ├─ editor/                      编辑器 UI
│  │  ├─ WorkshopHeader.vue        顶部：项目名、撤销重做、质量检查、预览、发布、更多菜单
│  │  ├─ PalettePanel.vue          组件库（可拖拽）
│  │  ├─ TemplatePanel.vue         场景模板
│  │  ├─ PagesPanel.vue            页面列表 + 活动信息
│  │  ├─ PhoneScreen.vue           手机画布：选中框、拖拽排序、拖放插入、表单校验上下文
│  │  ├─ BlockView.vue             13 种组件的纯渲染（编辑器与预览共用）
│  │  ├─ InspectorPanel.vue        属性 / 样式
│  │  ├─ AiPanel.vue               AI 对话 + 建议卡片
│  │  └─ fields/                   表单字段、信息行、按钮动作的子编辑器
│  ├─ modals/                      创建 / 预览 / 发布 / 质量检查
│  └─ ui/                          Icon、BaseModal、QrCode、ToastHost
├─ stores/editor.ts                Pinia：文档、页面、撤销栈、自动保存、发布
├─ services/
│  ├─ agent.ts                     智能体 HTTP 客户端（/health、/chat、超时、错误码）
│  ├─ planner.ts                   方案 schema 校验、文本结构解析、本地规则生成
│  ├─ copilot.ts                   本地建议引擎 + 兜底回复
│  ├─ quality.ts                   质量检查规则
│  ├─ exporters.ts                 JSON / 静态 HTML 导出
│  └─ poster.ts                    Canvas 分享海报
├─ data/                          组件目录（含属性 schema）、模板、SVG 占位图
├─ types/editor.ts                数据模型（Doc / Page / Block / Theme / DocPlan …）
└─ utils/                         主题变量、日期、id、slug
```

## 和后端 / 智能体怎么对接

当前只依赖一个约定：**智能体返回结构化 JSON**，前端负责校验和落地。

```jsonc
// POST /chat 的回复里（或整段回复）是这个结构即可
{
  "title": "光影摄影社招新",
  "reason": "为什么这样排页面",
  "theme": { "primary": "#4f46e5", "accent": "#8b5cf6", "bg": "#f7f8fc", "text": "#111827" },
  "meta": { "org": "光影摄影社", "startAt": "10月26日 19:00", "place": "三教 402" },
  "pages": [
    {
      "name": "首页",
      "role": "home",
      "blocks": [
        { "type": "nav", "props": { "title": "光影摄影社" } },
        { "type": "button", "props": { "text": "立即报名", "action": { "type": "page", "targetRole": "form" } } },
      ],
    },
  ],
}
```

- `type` 只认 13 种受控组件，未知类型会被丢掉，不会执行任何 HTML/JS（`normalizePlan` 里做白名单校验）
- `role` 只用 `home / content / form / success`，按钮 `action.targetRole` 用它找目标页
- 智能体地址：默认 `http://127.0.0.1:8000`，可在 AI 面板「智能体设置」里改（存 localStorage），也支持 `VITE_AGENT_BASE_URL` 环境变量
- 后端接好之后，把 `stores/editor.ts` 的保存 / 发布换成真实接口，其余组件不用动

## 还没做的（按 PRD 属于后端 / 下一版）

- 真实登录、项目云同步、多人协作
- 报名数据收集与 CSV 导出、投票/打卡统计
- 海报 OCR（现在是「离线演示」占位：不让用户以为已经识别了）
- 微信小程序原生能力、自定义域名、在线支付

## 约定

- **不生成可执行 HTML/CSS/JS**：AI 只输出组件结构，渲染层只有 `BlockView.vue`
- 所有用户/模型文本都走文本插值，没有 `v-html` 渲染用户内容（Icon 里的 `v-html` 是内置静态图标）
- 破坏性操作（套模板、应用 AI 方案、删组件）都能撤销
- 时间类数据一律动态计算，别写死年份
