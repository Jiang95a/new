/**
 * 编辑器数据模型。
 *
 * 一条铁律：页面结构必须是「受控组件」——类型固定、属性受 schema 约束、
 * 不存 HTML/CSS/JS。AI 也只能产出这个结构（见 services/planner.ts 的 normalizePlan）。
 */

export const BLOCK_TYPES = [
  'nav',
  'banner',
  'heading',
  'text',
  'image',
  'infoCard',
  'button',
  'form',
  'radio',
  'checkbox',
  'qrcode',
  'divider',
  'countdown',
] as const

export type BlockType = (typeof BLOCK_TYPES)[number]

export function isBlockType(value: unknown): value is BlockType {
  return typeof value === 'string' && (BLOCK_TYPES as readonly string[]).includes(value)
}

export type Align = 'left' | 'center' | 'right'

/** 通用外框样式：任何组件都能改这几项，不需要为每个类型单独写一遍 */
export interface BlockStyle {
  bg: string
  paddingX: number
  paddingY: number
  radius: number
  align: Align
}

export interface Block {
  id: string
  type: BlockType
  /** 组件自有属性。属性面板的字段由 data/blockCatalog.ts 声明，这里保持宽松 */
  props: Record<string, any>
  style: BlockStyle
  hidden: boolean
}

export type PageRole = 'home' | 'content' | 'form' | 'success'

export interface Page {
  id: string
  name: string
  role: PageRole
  blocks: Block[]
  bg: string
}

export type ButtonStyle = 'solid' | 'gradient' | 'outline'
export type FontKind = 'sans' | 'serif' | 'round'

export interface Theme {
  primary: string
  accent: string
  bg: string
  text: string
  radius: number
  /** 全局字号倍率 0.9 ~ 1.2 */
  fontScale: number
  /** 全局间距倍率 0.8 ~ 1.6 */
  spacing: number
  buttonStyle: ButtonStyle
  font: FontKind
}

export interface DocMeta {
  org: string
  startAt: string
  place: string
  deadline: string
  /** 0 表示不限人数 */
  capacity: number
  contact: string
}

export interface PublishInfo {
  url: string
  slug: string
  at: number
}

export interface Doc {
  id: string
  title: string
  slug: string
  theme: Theme
  pages: Page[]
  meta: DocMeta
  createdAt: number
  updatedAt: number
  published: PublishInfo | null
}

/**
 * 对外统一使用 PageDocument 命名；现有编辑器和历史本地数据
 * 继续使用等价的 Doc 类型，避免迁移造成大范围重命名。
 */
export type PageDocument = Doc

/* ------------------------------- 表单 / 属性 ------------------------------- */

export type FieldType = 'text' | 'tel' | 'email' | 'textarea' | 'select' | 'radio' | 'checkbox'

export interface FormField {
  id: string
  label: string
  type: FieldType
  required: boolean
  placeholder: string
  options: string[]
}

export type InfoIcon = 'time' | 'place' | 'org' | 'people' | 'ticket' | 'contact'

export interface InfoItem {
  id: string
  icon: InfoIcon
  label: string
  value: string
}

export type ButtonActionType = 'page' | 'url' | 'submit' | 'none'

export interface ButtonAction {
  type: ButtonActionType
  pageId: string
  url: string
}

/* ------------------------------- AI 产物 ------------------------------- */

export interface BlockPlan {
  type: BlockType
  props?: Record<string, any>
}

export interface PagePlan {
  name: string
  role: PageRole
  blocks: BlockPlan[]
}

export interface DocPlan {
  intent: string
  reason: string
  theme?: Partial<Theme>
  title?: string
  meta?: Partial<DocMeta>
  pages: PagePlan[]
  /** 这份方案是谁产出的，界面上要如实标注 */
  source?: 'agent' | 'local' | 'template'
}

export type IssueLevel = 'error' | 'warn' | 'info'

export interface Issue {
  id: string
  level: IssueLevel
  title: string
  detail: string
  pageId: string
  blockId?: string
}

export interface Suggestion {
  id: string
  title: string
  reason: string
  pageId: string
  blockId?: string
  patch?: {
    props?: Record<string, any>
    style?: Partial<BlockStyle>
    theme?: Partial<Theme>
  }
  before?: string
  after?: string
}

/* ------------------------------- 属性面板 schema ------------------------------- */

export interface FieldOption {
  label: string
  value: string
}

export type FieldDef =
  | {
      kind: 'text'
      key: string
      label: string
      placeholder?: string
      maxlength?: number
      hint?: string
    }
  | {
      kind: 'textarea'
      key: string
      label: string
      placeholder?: string
      rows?: number
      maxlength?: number
    }
  | {
      kind: 'number'
      key: string
      label: string
      min?: number
      max?: number
      step?: number
      unit?: string
    }
  | { kind: 'color'; key: string; label: string }
  | { kind: 'switch'; key: string; label: string; hint?: string }
  | { kind: 'select'; key: string; label: string; options: FieldOption[] }
  | { kind: 'lines'; key: string; label: string; placeholder?: string; hint?: string }
  | { kind: 'fields'; key: string; label: string }
  | { kind: 'items'; key: string; label: string }
  | { kind: 'action'; key: string; label: string }
