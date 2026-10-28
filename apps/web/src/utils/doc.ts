import type { Block, Doc, Page, PageRole } from '@/types/editor'
import { isBlockType } from '@/types/editor'
import { DEFAULT_BLOCK_STYLE, DEFAULT_THEME } from '@/data/blockCatalog'
import { slugify, uid } from './misc'

export function findPage(pages: Page[], pageId: string): Page | undefined {
  return pages.find((page) => page.id === pageId)
}

export function firstPageOfRole(pages: Page[], role: PageRole): Page | undefined {
  return pages.find((page) => page.role === role)
}

/**
 * 模板里写的按钮还不知道页面 id，所以先用 targetRole 占位，
 * 建完再看一眼把真实 id 补上。
 */
export function linkPages(pages: Page[]): void {
  for (const page of pages) {
    for (const block of page.blocks) {
      if (block.type !== 'button') continue
      const action = block.props.action
      if (!action || action.type !== 'page' || action.pageId) continue
      const target = action.targetRole ? pages.find((item) => item.role === action.targetRole) : undefined
      if (target) action.pageId = target.id
    }
  }
}

export function makePage(name: string, role: PageRole, blocks: Block[], bg = ''): Page {
  return { id: uid('page'), name, role, blocks, bg }
}

export function nextPage(pages: Page[], currentId: string): Page | undefined {
  const index = pages.findIndex((page) => page.id === currentId)
  if (index < 0) return pages[0]
  return pages[index + 1] ?? pages[0]
}

export function clonePageDeep(page: Page): Page {
  return JSON.parse(JSON.stringify(page)) as Page
}

const ROLES: PageRole[] = ['home', 'content', 'form', 'success']

/**
 * 把「来路不明的 JSON」修成一份能安全渲染的文档。
 * 本地缓存、用户导入、以后后端返回的数据都从这里过一遍，
 * 缺 theme / meta / style 的旧数据不至于把画布搞崩。
 */
export function normalizeDoc(raw: unknown): Doc | null {
  if (!raw || typeof raw !== 'object') return null
  const record = raw as Record<string, any>
  if (typeof record.title !== 'string' || !Array.isArray(record.pages)) return null

  const pages: Page[] = []
  record.pages.forEach((item: any, index: number) => {
    if (!item || typeof item !== 'object') return
    const blocks: Block[] = []
    const rawBlocks = Array.isArray(item.blocks) ? item.blocks : []
    rawBlocks.forEach((rawBlock: any) => {
      if (!rawBlock || !isBlockType(rawBlock.type)) return
      blocks.push({
        id: typeof rawBlock.id === 'string' ? rawBlock.id : uid('blk'),
        type: rawBlock.type,
        props: rawBlock.props && typeof rawBlock.props === 'object' ? rawBlock.props : {},
        style: { ...DEFAULT_BLOCK_STYLE, ...(rawBlock.style ?? {}) },
        hidden: Boolean(rawBlock.hidden),
      })
    })

    pages.push({
      id: typeof item.id === 'string' ? item.id : uid('page'),
      name: typeof item.name === 'string' && item.name.trim() ? item.name.slice(0, 16) : `页面 ${index + 1}`,
      role: ROLES.includes(item.role) ? item.role : 'content',
      bg: typeof item.bg === 'string' ? item.bg : '',
      blocks,
    })
  })

  if (!pages.length) return null
  if (!pages.some((page) => page.role === 'home')) {
    const first = pages[0]
    if (first) first.role = 'home'
  }

  const now = Date.now()
  return {
    id: typeof record.id === 'string' ? record.id : uid('doc'),
    title: record.title.slice(0, 40) || '未命名活动',
    slug: typeof record.slug === 'string' && record.slug ? record.slug : slugify(record.title),
    theme: { ...DEFAULT_THEME, ...(record.theme ?? {}) },
    pages,
    meta: {
      org: '',
      startAt: '',
      place: '',
      deadline: '',
      capacity: 0,
      contact: '',
      ...(record.meta ?? {}),
    },
    createdAt: typeof record.createdAt === 'number' ? record.createdAt : now,
    updatedAt: now,
    published: record.published && typeof record.published.url === 'string' ? record.published : null,
  }
}
