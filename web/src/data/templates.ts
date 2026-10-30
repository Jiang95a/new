import type { Doc, DocMeta, Page, Theme } from '@/types/editor'
import { createBlock, DEFAULT_THEME, THEME_PRESETS } from '@/data/blockCatalog'
import { placeholder } from '@/data/placeholderImages'
import { linkPages, makePage } from '@/utils/doc'
import { uid, slugify } from '@/utils/misc'

export interface TemplateBuild {
  title: string
  theme: Theme
  meta: DocMeta
  pages: Page[]
}

export interface TemplateDef {
  id: string
  name: string
  scene: string
  tagline: string
  icon: string
  gradient: [string, string]
  build: () => TemplateBuild
}

const block = createBlock

/**
 * 模板里的日期一律按「今天 + N 天」算。
 * 写死 2026-10-26 这种日期，过两个月演示就成了「报名已截止」，很致命。
 */
function dateOffset(offsetDays: number, hour = 19, minute = 0) {
  const date = new Date()
  date.setDate(date.getDate() + offsetDays)
  date.setHours(hour, minute, 0, 0)
  const pad = (value: number) => String(value).padStart(2, '0')
  const month = date.getMonth() + 1
  const day = date.getDate()
  const weekday = '日一二三四五六'.charAt(date.getDay())
  const clock = `${pad(hour)}:${pad(minute)}`
  return {
    clock,
    label: `${month}月${day}日 ${clock}`,
    labelWithWeek: `${month}月${day}日 周${weekday} ${clock}`,
    iso: `${date.getFullYear()}-${pad(month)}-${pad(day)} ${clock}`,
    withYear: `${date.getFullYear()}年${month}月${day}日 ${clock}`,
  }
}

function themeOf(presetId: string, patch: Partial<Theme> = {}): Theme {
  const preset = THEME_PRESETS.find((item) => item.id === presetId)
  return { ...DEFAULT_THEME, ...(preset?.theme ?? {}), ...patch }
}

function meta(patch: Partial<DocMeta> = {}): DocMeta {
  return {
    org: '校园社团',
    startAt: '',
    place: '',
    deadline: '',
    capacity: 0,
    contact: '',
    ...patch,
  }
}

/* ------------------------------------------------------------------------- */
/* 演示文档：摄影社招新（四页，13 种组件全用上）                                  */
/* ------------------------------------------------------------------------- */

function buildPhotographyRecruit(): TemplateBuild {
  const interview = dateOffset(5, 19, 0)
  const deadline = dateOffset(4, 22, 0)

  const home = makePage('首页', 'home', [
    block('nav', { title: '光影摄影社', right: '2026 秋招', showBack: false }),
    block('banner', {
      title: '把秋天装进相机里',
      subtitle: '光影摄影社 2026 秋季招新',
      image: placeholder('ink'),
      height: 258,
    }),
    block('countdown', {
      target: deadline.iso,
      label: '报名截止还有',
      doneText: '报名已截止',
    }),
    block('infoCard', {
      title: '招新信息',
      items: [
        { id: uid('it'), icon: 'time', label: '面试时间', value: interview.label },
        { id: uid('it'), icon: 'place', label: '地点', value: '三教 402 阶梯教室' },
        { id: uid('it'), icon: 'people', label: '名额', value: '60 人（不限年级）' },
        { id: uid('it'), icon: 'contact', label: '联系', value: '微信 shiguang2026' },
      ],
    }),
    block('text', {
      text: '我们不只有长枪短炮。手机也能拍。\n每周一次夜拍，每月一次外拍，期末办一次展。',
    }),
    block('button', {
      text: '立即报名',
      variant: 'primary',
      full: true,
      action: { type: 'page', pageId: '', url: '', targetRole: 'form' },
    }),
  ])

  const about = makePage('社团介绍', 'content', [
    block('nav', { title: '关于光影', right: '', showBack: true }),
    block('heading', {
      text: '一群爱拍照的人',
      sub: '成立于 2016 年 · 累计 240+ 成员',
      size: 'lg',
    }),
    block('text', {
      text: '光影摄影社是校内最早成立的影像社团。我们有暗房、有器材柜、有每月一次的评片会。\n\n不管你是刚买第一台相机，还是已经在接商单，这里都有人陪你把照片拍得更好。',
    }),
    block('image', {
      url: placeholder('ocean'),
      caption: '2025 年秋 · 东山外拍',
      ratio: '4:3',
    }),
    block('divider', { label: '我们拍什么' }),
    block('text', {
      text: '人像 · 街拍 · 风光 · 胶片冲洗 · 短片剪辑\n每周三晚 19:00 在 3 号楼 501 有固定活动，随时来蹭。',
    }),
  ])

  const form = makePage('报名表单', 'form', [
    block('nav', { title: '填写报名信息', right: '', showBack: true }),
    block('text', {
      text: '填完提交就行。我们会在 24 小时内微信联系你，面试当天带上你的三张作品（手机拍的也算）。',
    }),
    block('radio', {
      question: '想加入哪个组？',
      options: ['人像组', '街拍组', '风光组', '后期组'],
      required: true,
      hint: '没想好也没关系，面试时可以改',
    }),
    block('checkbox', {
      question: '你感兴趣的方向',
      options: ['外拍活动', '暗房冲洗', '短片拍摄', '社团宣传'],
      required: false,
      max: 2,
      hint: '最多选 2 项',
    }),
    block('form', {
      title: '基本信息',
      buttonText: '提交报名',
      successHint: '提交后请留意微信消息',
      fields: [
        {
          id: uid('f'),
          label: '姓名',
          type: 'text',
          required: true,
          placeholder: '怎么称呼你',
          options: [],
        },
        {
          id: uid('f'),
          label: '学号',
          type: 'text',
          required: true,
          placeholder: '用于核对身份',
          options: [],
        },
        {
          id: uid('f'),
          label: '手机号',
          type: 'tel',
          required: true,
          placeholder: '11 位手机号',
          options: [],
        },
        {
          id: uid('f'),
          label: '微信号',
          type: 'text',
          required: true,
          placeholder: '方便拉你进面试群',
          options: [],
        },
        {
          id: uid('f'),
          label: '你有相机吗？',
          type: 'select',
          required: true,
          placeholder: '请选择',
          options: ['有单反/微单', '只有手机', '想借社团的器材'],
        },
        {
          id: uid('f'),
          label: '说点什么',
          type: 'textarea',
          required: false,
          placeholder: '最近拍的一张照片是怎样的？',
          options: [],
        },
      ],
    }),
  ])

  const success = makePage('报名成功', 'success', [
    block('nav', { title: '报名成功', right: '', showBack: false }),
    block('heading', {
      text: '收到啦，欢迎加入',
      sub: '我们已经记下你的报名信息',
      size: 'xl',
    }),
    block('text', {
      text: `面试时间：${interview.label}\n地点：三教 402 阶梯教室\n\n记得带上三张作品，手机拍的也算。`,
    }),
    block('qrcode', { url: '', label: '扫码进面试通知群', size: 138 }),
    block('button', {
      text: '返回首页',
      variant: 'outline',
      full: true,
      action: { type: 'page', pageId: '', url: '', targetRole: 'home' },
    }),
  ])

  const pages = [home, about, form, success]
  linkPages(pages)

  return {
    title: '光影摄影社 · 2026 秋季招新',
    theme: themeOf('graphite', {
      primary: '#1f2937',
      accent: '#f59e0b',
      bg: '#faf8f5',
      radius: 14,
      buttonStyle: 'solid',
      fontScale: 1,
      spacing: 1,
    }),
    meta: meta({
      org: '光影摄影社',
      startAt: interview.withYear,
      place: '三教 402 阶梯教室',
      deadline: deadline.iso,
      capacity: 60,
      contact: '微信 shiguang2026',
    }),
    pages,
  }
}

/* ------------------------------------------------------------------------- */
/* 四个场景模板                                                                */
/* ------------------------------------------------------------------------- */

function buildSignup(): TemplateBuild {
  const run = dateOffset(9, 18, 30)
  const deadline = dateOffset(8, 20, 0)

  const home = makePage('首页', 'home', [
    block('nav', { title: '校园荧光夜跑', right: '', showBack: false }),
    block('banner', {
      title: '周五夜跑，一起发光',
      subtitle: '第四届校园荧光夜跑 · 3 公里',
      image: placeholder('dusk'),
      height: 246,
    }),
    block('infoCard', {
      title: '活动信息',
      items: [
        { id: uid('it'), icon: 'time', label: '时间', value: run.labelWithWeek },
        { id: uid('it'), icon: 'place', label: '集合', value: '东区操场看台下' },
        { id: uid('it'), icon: 'ticket', label: '费用', value: '免费（含荧光手环）' },
      ],
    }),
    block('countdown', {
      target: deadline.iso,
      label: '报名截止还有',
      doneText: '报名已截止',
    }),
    block('button', {
      text: '我要参加',
      variant: 'primary',
      full: true,
      action: { type: 'page', pageId: '', url: '', targetRole: 'form' },
    }),
  ])

  const detail = makePage('路线说明', 'content', [
    block('nav', { title: '路线与规则', right: '', showBack: true }),
    block('heading', { text: '3 公里 · 两圈半', size: 'lg' }),
    block('image', {
      url: placeholder('forest'),
      caption: '沿途经过图书馆、樱花园、南门',
      ratio: '16:9',
    }),
    block('text', {
      text: '1. 18:00 检录领手环，18:30 统一出发；\n2. 每个补给点可以打卡，集齐 3 个章有纪念徽章；\n3. 不计名次，走完全程也算完成。',
    }),
    block('divider', { label: '' }),
    block('text', { text: '安全提示：穿反光衣物，膝盖有伤的别硬撑。' }),
  ])

  const form = makePage('报名', 'form', [
    block('nav', { title: '报名信息', right: '', showBack: true }),
    block('form', {
      title: '参加者信息',
      buttonText: '确认报名',
      successHint: '提交后凭手机号现场检录',
      fields: [
        {
          id: uid('f'),
          label: '姓名',
          type: 'text',
          required: true,
          placeholder: '请输入姓名',
          options: [],
        },
        {
          id: uid('f'),
          label: '学号',
          type: 'text',
          required: true,
          placeholder: '请输入学号',
          options: [],
        },
        {
          id: uid('f'),
          label: '手机号',
          type: 'tel',
          required: true,
          placeholder: '紧急联系人会用',
          options: [],
        },
        {
          id: uid('f'),
          label: 'T 恤尺码',
          type: 'select',
          required: true,
          placeholder: '请选择',
          options: ['S', 'M', 'L', 'XL'],
        },
      ],
    }),
    block('checkbox', {
      question: '有需要提前说明的情况吗',
      options: ['膝踝旧伤', '哮喘/心脏问题', '当天会晚到'],
      required: false,
      max: 3,
      hint: '可多选，我们会单独联系你',
    }),
  ])

  const success = makePage('报名成功', 'success', [
    block('nav', { title: '报名成功', right: '', showBack: false }),
    block('heading', { text: '周五见', sub: '凭手机号现场检录', size: 'xl' }),
    block('text', {
      text: '18:00 东区操场看台下领荧光手环，别迟到。\n下雨顺延到周六同一时间。',
    }),
    block('qrcode', { url: '', label: '扫码加入活动群', size: 132 }),
  ])

  const pages = [home, detail, form, success]
  linkPages(pages)
  return {
    title: '第四届校园荧光夜跑',
    theme: themeOf('sunset', { radius: 18 }),
    meta: meta({
      org: '校学生会体育部',
      startAt: run.withYear,
      place: '东区操场',
      deadline: deadline.iso,
      capacity: 200,
      contact: '体育部 张同学',
    }),
    pages,
  }
}

function buildVote(): TemplateBuild {
  const deadline = dateOffset(6, 20, 0)

  const home = makePage('首页', 'home', [
    block('nav', { title: '摄影大赛 · 人气票选', right: '', showBack: false }),
    block('banner', {
      title: '2026 校园摄影大赛',
      subtitle: '人气作品投票 · 每人 1 票',
      image: placeholder('clay'),
      height: 230,
    }),
    block('text', {
      text: `从 126 份投稿里选出了 8 组入围作品。投出你心里的第一张。\n投票截止到 ${deadline.label}。`,
    }),
    block('infoCard', {
      title: '投票说明',
      items: [
        { id: uid('it'), icon: 'time', label: '截止', value: deadline.label },
        { id: uid('it'), icon: 'org', label: '主办', value: '光影摄影社' },
        { id: uid('it'), icon: 'people', label: '参与', value: '全校师生' },
      ],
    }),
    block('button', {
      text: '去投票',
      variant: 'primary',
      full: true,
      action: { type: 'page', pageId: '', url: '', targetRole: 'form' },
    }),
  ])

  const vote = makePage('投票', 'form', [
    block('nav', { title: '选择作品', right: '', showBack: true }),
    block('heading', { text: '只投一票，投完不能改', size: 'md' }),
    block('radio', {
      question: '你最喜欢哪一组？',
      options: ['01 · 图书馆的午后', '02 · 雨后的操场', '03 · 食堂窗口', '04 · 深夜自习室', '05 · 樱花道'],
      required: true,
      hint: '作品详情见展板',
    }),
    block('form', {
      title: '投票人信息',
      buttonText: '提交投票',
      successHint: '每人限投一次，重复提交以第一次为准',
      fields: [
        {
          id: uid('f'),
          label: '学号',
          type: 'text',
          required: true,
          placeholder: '用于去重',
          options: [],
        },
        {
          id: uid('f'),
          label: '姓名',
          type: 'text',
          required: true,
          placeholder: '可选填',
          options: [],
        },
      ],
    }),
  ])

  const result = makePage('投票成功', 'success', [
    block('nav', { title: '投票成功', right: '', showBack: false }),
    block('heading', { text: '投出去了', sub: '结果会在截止后 3 天内公布', size: 'xl' }),
    block('text', {
      text: '结果会贴在社团公告栏，也会发到公众号。颁奖礼在结果公布后一周。',
    }),
    block('qrcode', { url: '', label: '扫码看实时排名', size: 132 }),
  ])

  const pages = [home, vote, result]
  linkPages(pages)
  return {
    title: '2026 校园摄影大赛 · 人气票选',
    theme: themeOf('rose', { radius: 20, buttonStyle: 'gradient' }),
    meta: meta({
      org: '光影摄影社',
      startAt: deadline.withYear,
      place: '线上投票',
      deadline: deadline.iso,
      capacity: 0,
      contact: '公众号「光影摄影社」',
    }),
    pages,
  }
}

function buildCheckin(): TemplateBuild {
  const start = dateOffset(4, 6, 30)
  const deadline = dateOffset(3, 22, 0)

  const home = makePage('首页', 'home', [
    block('nav', { title: '14 天早起挑战', right: '', showBack: false }),
    block('banner', {
      title: '早起 14 天，把早晨还给自己',
      subtitle: '每天 6:30 打卡 · 连续 14 天有奖',
      image: placeholder('dawn'),
      height: 236,
    }),
    block('countdown', {
      target: start.iso,
      label: '挑战开始还有',
      doneText: '挑战已开始',
    }),
    block('text', {
      text: '打卡方式：每天早上拍一张天亮的照片，配一句话。\n连续 14 天完成的同学，发放定制马克杯。',
    }),
    block('button', {
      text: '我要参加',
      variant: 'primary',
      full: true,
      action: { type: 'page', pageId: '', url: '', targetRole: 'form' },
    }),
  ])

  const checkin = makePage('每日打卡', 'form', [
    block('nav', { title: '今日打卡', right: '第 1 天', showBack: true }),
    block('radio', {
      question: '今天几点起的？',
      options: ['6:00 之前', '6:00 - 6:30', '6:30 - 7:00', '7:00 之后'],
      required: true,
      hint: '诚实一点，我们不查岗',
    }),
    block('form', {
      title: '打卡内容',
      buttonText: '提交打卡',
      successHint: '每天只能打卡一次',
      fields: [
        {
          id: uid('f'),
          label: '昵称',
          type: 'text',
          required: true,
          placeholder: '排行榜上显示的名字',
          options: [],
        },
        {
          id: uid('f'),
          label: '今天的一句话',
          type: 'textarea',
          required: true,
          placeholder: '例如：五点半的天是灰蓝色的',
          options: [],
        },
      ],
    }),
  ])

  const success = makePage('打卡成功', 'success', [
    block('nav', { title: '打卡成功', right: '', showBack: false }),
    block('heading', { text: '第 1 天，完成', sub: '连续 1 / 14 天', size: 'xl' }),
    block('text', { text: '明天早上 6:30 见。\n断签了可以重来，但奖品就没了。' }),
    block('qrcode', { url: '', label: '扫码看排行榜', size: 132 }),
  ])

  const pages = [home, checkin, success]
  linkPages(pages)
  return {
    title: '14 天早起打卡挑战',
    theme: themeOf('forest', { radius: 18 }),
    meta: meta({
      org: '自律互助小组',
      startAt: start.withYear,
      place: '线上打卡',
      deadline: deadline.iso,
      capacity: 0,
      contact: '群公告',
    }),
    pages,
  }
}

function buildClubRecruit(): TemplateBuild {
  const talk = dateOffset(3, 19, 0)
  const deadline = dateOffset(2, 22, 0)

  const home = makePage('首页', 'home', [
    block('nav', { title: '招新啦', right: '2026 秋', showBack: false }),
    block('banner', {
      title: '加入我们，一起搞点事情',
      subtitle: '校学生会 · 2026 秋季招新',
      image: placeholder('dusk'),
      height: 244,
    }),
    block('text', {
      text: '我们不缺打杂的，缺能拿主意的人。\n四个部门同时开招，选一个你喜欢的。',
    }),
    block('infoCard', {
      title: '招新安排',
      items: [
        { id: uid('it'), icon: 'time', label: '宣讲会', value: talk.label },
        { id: uid('it'), icon: 'place', label: '地点', value: '图书馆报告厅' },
        { id: uid('it'), icon: 'contact', label: '咨询', value: '扫码进群' },
      ],
    }),
    block('button', {
      text: '报名加入',
      variant: 'primary',
      full: true,
      action: { type: 'page', pageId: '', url: '', targetRole: 'form' },
    }),
  ])

  const dept = makePage('部门介绍', 'content', [
    block('nav', { title: '四个部门', right: '', showBack: true }),
    block('heading', { text: '你想做哪一块', size: 'lg' }),
    block('text', {
      text: '活动部：策划落地，最能练手。\n宣传部：写文案、做图、运营公众号。\n技术部：做小程序、搭网站。\n外联部：找赞助，和商家谈。',
    }),
    block('image', {
      url: placeholder('ocean'),
      caption: '去年的迎新之夜',
      ratio: '16:9',
    }),
    block('divider', { label: '' }),
    block('text', { text: '每个部门都接受零基础，我们有老人带。' }),
  ])

  const form = makePage('报名表单', 'form', [
    block('nav', { title: '报名', right: '', showBack: true }),
    block('radio', {
      question: '第一志愿',
      options: ['活动部', '宣传部', '技术部', '外联部'],
      required: true,
      hint: '面试时会聊为什么选它',
    }),
    block('form', {
      title: '基本信息',
      buttonText: '提交报名',
      successHint: '我们会在 3 天内短信通知',
      fields: [
        {
          id: uid('f'),
          label: '姓名',
          type: 'text',
          required: true,
          placeholder: '请输入姓名',
          options: [],
        },
        {
          id: uid('f'),
          label: '班级',
          type: 'text',
          required: true,
          placeholder: '如 软件2504',
          options: [],
        },
        {
          id: uid('f'),
          label: '手机号',
          type: 'tel',
          required: true,
          placeholder: '11 位手机号',
          options: [],
        },
      ],
    }),
  ])

  const success = makePage('报名成功', 'success', [
    block('nav', { title: '报名成功', right: '', showBack: false }),
    block('heading', { text: '报名收到', sub: '面试通知会发到你的手机', size: 'xl' }),
    block('text', { text: '记得在面试前想清楚：你想在这待多久，想带走什么。' }),
    block('qrcode', { url: '', label: '扫码进招新群', size: 132 }),
  ])

  const pages = [home, dept, form, success]
  linkPages(pages)
  return {
    title: '校学生会 2026 秋季招新',
    theme: themeOf('indigo', { radius: 16 }),
    meta: meta({
      org: '校学生会',
      startAt: talk.withYear,
      place: '图书馆报告厅',
      deadline: deadline.iso,
      capacity: 80,
      contact: '招新群',
    }),
    pages,
  }
}

export const TEMPLATES: TemplateDef[] = [
  {
    id: 'recruit',
    name: '社团招新',
    scene: '招新 / 纳新',
    tagline: '介绍 + 部门 + 报名表单',
    icon: 'users',
    gradient: ['#6366f1', '#a855f7'],
    build: buildClubRecruit,
  },
  {
    id: 'signup',
    name: '活动报名',
    scene: '讲座 / 比赛 / 夜跑',
    tagline: '信息卡 + 倒计时 + 报名',
    icon: 'zap',
    gradient: ['#f97316', '#f43f5e'],
    build: buildSignup,
  },
  {
    id: 'vote',
    name: '投票评选',
    scene: '比赛 / 评选',
    tagline: '作品展示 + 单选投票',
    icon: 'check-circle',
    gradient: ['#db2777', '#f472b6'],
    build: buildVote,
  },
  {
    id: 'checkin',
    name: '每日打卡',
    scene: '打卡 / 挑战',
    tagline: '倒计时 + 每日提交',
    icon: 'clock',
    gradient: ['#059669', '#84cc16'],
    build: buildCheckin,
  },
]

export function templateById(id: string): TemplateDef | undefined {
  return TEMPLATES.find((item) => item.id === id)
}

/* ------------------------------- Doc 工厂 ------------------------------- */

export function newDocFromBuild(build: TemplateBuild, existing?: Doc): Doc {
  const now = Date.now()
  return {
    id: existing?.id ?? uid('doc'),
    title: build.title,
    slug: existing?.slug ?? slugify(build.title),
    theme: build.theme,
    pages: build.pages,
    meta: build.meta,
    createdAt: existing?.createdAt ?? now,
    updatedAt: now,
    published: null,
  }
}

/** 首次打开时的演示文档：直接能看到成品的四页活动站 */
export function createDemoDoc(): Doc {
  return newDocFromBuild(buildPhotographyRecruit())
}

export function createBlankDoc(): Doc {
  const pages = [makePage('首页', 'home', [block('nav', { title: '活动标题', right: '', showBack: false })])]
  return newDocFromBuild({
    title: '未命名活动',
    theme: { ...DEFAULT_THEME },
    meta: meta(),
    pages,
  })
}

export function createDocFromTemplate(id: string, existing?: Doc): Doc {
  const template = templateById(id)
  if (!template) return createBlankDoc()
  return newDocFromBuild(template.build(), existing)
}

/** 给「海报解析」演示步骤用：从字段生成一个可用的三页方案 */
export function buildQuickDoc(input: {
  title: string
  org: string
  startAt: string
  place: string
  deadline: string
  capacity: number
  contact: string
}): TemplateBuild {
  const home = makePage('首页', 'home', [
    block('nav', { title: input.title || '活动报名', right: '', showBack: false }),
    block('banner', {
      title: input.title || '活动名称',
      subtitle: input.org ? `${input.org} 主办` : '欢迎参加',
      image: placeholder('dusk'),
      height: 240,
    }),
    block('infoCard', {
      title: '活动信息',
      items: [
        { id: uid('it'), icon: 'time', label: '时间', value: input.startAt || '待补充' },
        { id: uid('it'), icon: 'place', label: '地点', value: input.place || '待补充' },
        { id: uid('it'), icon: 'org', label: '主办', value: input.org || '待补充' },
      ],
    }),
    block('text', {
      text: '这里放活动介绍。先用一句话说清：谁办的、干什么的、为什么值得来。',
    }),
    block('button', {
      text: '立即报名',
      variant: 'primary',
      full: true,
      action: { type: 'page', pageId: '', url: '', targetRole: 'form' },
    }),
  ])

  const form = makePage('报名表单', 'form', [
    block('nav', { title: '报名信息', right: '', showBack: true }),
    block('form', {
      title: '填写信息',
      buttonText: '提交报名',
      successHint: '提交后我们会尽快联系你',
      fields: [
        {
          id: uid('f'),
          label: '姓名',
          type: 'text',
          required: true,
          placeholder: '请输入姓名',
          options: [],
        },
        {
          id: uid('f'),
          label: '手机号',
          type: 'tel',
          required: true,
          placeholder: '11 位手机号',
          options: [],
        },
        {
          id: uid('f'),
          label: '备注',
          type: 'textarea',
          required: false,
          placeholder: '有什么想说的',
          options: [],
        },
      ],
    }),
  ])

  const success = makePage('报名成功', 'success', [
    block('nav', { title: '报名成功', right: '', showBack: false }),
    block('heading', { text: '报名成功', sub: '我们会尽快联系你', size: 'xl' }),
    block('text', {
      text: `${input.startAt || '时间待定'} · ${input.place || '地点待定'}`,
    }),
    block('qrcode', { url: '', label: '扫码查看活动详情', size: 132 }),
  ])

  const pages = [home, form, success]
  linkPages(pages)
  return {
    title: input.title || '未命名活动',
    theme: themeOf('indigo', { radius: 16 }),
    meta: meta({
      org: input.org,
      startAt: input.startAt,
      place: input.place,
      deadline: input.deadline,
      capacity: input.capacity,
      contact: input.contact,
    }),
    pages,
  }
}

/** 供「随机配色」用 */
export function randomTheme(current: Theme): Theme {
  const preset = THEME_PRESETS[Math.floor(Math.random() * THEME_PRESETS.length)] as (typeof THEME_PRESETS)[number]
  return { ...current, ...preset.theme }
}
