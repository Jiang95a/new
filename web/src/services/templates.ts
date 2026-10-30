import type { Doc } from '@/types/editor'
import { TEMPLATES, createDocFromTemplate } from '@/data/templates'
import { normalizePlan, planToDoc } from '@/services/planner'
import { normalizeDoc } from '@/utils/doc'
import { apiRequest, readData } from './http'

interface TemplateApiRecord {
  id: string
  code: string
  name: string
  category: string
  description?: string
  coverUrl?: string
  document: unknown
}

export interface TemplateCatalogItem {
  id: string
  code: string
  name: string
  category: string
  scene: string
  tagline: string
  icon: string
  gradient: [string, string]
  source: 'remote' | 'local'
  build: () => Doc
}

const CATEGORY_META: Record<string, { scene: string; icon: string; gradient: [string, string] }> = {
  recruitment: { scene: '社团招新', icon: 'users', gradient: ['#6366f1', '#a855f7'] },
  registration: { scene: '活动报名', icon: 'zap', gradient: ['#f97316', '#f43f5e'] },
  vote: { scene: '投票评选', icon: 'check-circle', gradient: ['#db2777', '#f472b6'] },
  checkin: { scene: '每日打卡', icon: 'clock', gradient: ['#059669', '#84cc16'] },
}

function toDoc(document: unknown): Doc | null {
  const normalized = normalizeDoc(document)
  if (normalized) return normalized
  const plan = normalizePlan(document)
  return plan ? planToDoc(plan) : null
}

function remoteItem(template: TemplateApiRecord): TemplateCatalogItem {
  const meta = CATEGORY_META[template.category] ?? {
    scene: template.category || '校园活动',
    icon: 'grid',
    gradient: ['#2563eb', '#7c3aed'] as [string, string],
  }
  return {
    id: template.id,
    code: template.code,
    name: template.name,
    category: template.category,
    scene: meta.scene,
    tagline: template.description || `${template.name}模板`,
    icon: meta.icon,
    gradient: meta.gradient,
    source: 'remote',
    build: () => toDoc(template.document) ?? createDocFromTemplate('recruit'),
  }
}

const localItems: TemplateCatalogItem[] = TEMPLATES.map((template) => ({
  id: template.id,
  code: template.id,
  name: template.name,
  category: template.id,
  scene: template.scene,
  tagline: template.tagline,
  icon: template.icon,
  gradient: template.gradient,
  source: 'local',
  build: () => createDocFromTemplate(template.id),
}))

export async function loadTemplateCatalog(): Promise<TemplateCatalogItem[]> {
  try {
    const data = readData<TemplateApiRecord[]>(await apiRequest('/templates'))
    if (Array.isArray(data) && data.length) return data.map(remoteItem)
  } catch {
    // 后端不可用时继续使用本地模板，保证演示和编辑流程不中断。
  }
  return localItems
}

export async function loadTemplateDocument(id: string): Promise<Doc> {
  try {
    const data = readData<TemplateApiRecord>(await apiRequest(`/templates/${encodeURIComponent(id)}`))
    const doc = toDoc(data.document)
    if (doc) return doc
  } catch {
    // 静态模板 id 在后端不存在时回退到本地构建。
  }
  return createDocFromTemplate(id)
}
