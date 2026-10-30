import type { Doc } from '@/types/editor'
import { normalizeDoc } from '@/utils/doc'
import { apiRequest, readData } from './http'

export interface DraftResponse {
  revision: number
  document: Doc
  updatedAt?: string
}

export async function getDraft(projectId: string): Promise<DraftResponse> {
  const data = readData<{
    revision?: number
    draftRevision?: number
    document?: unknown
    draftDocument?: unknown
    updatedAt?: string
  }>(await apiRequest(`/projects/${projectId}/draft`))
  const document = normalizeDoc(data.document ?? data.draftDocument)
  if (!document) throw new Error('后端返回的 PageDocument 结构无效')
  return {
    revision: Number(data.revision ?? data.draftRevision) || 0,
    document,
    updatedAt: data.updatedAt,
  }
}

export async function putDraft(projectId: string, baseRevision: number, document: Doc): Promise<DraftResponse> {
  const data = readData<{ revision?: number; draftRevision?: number; savedAt?: string }>(
    await apiRequest(`/projects/${projectId}/draft`, {
      method: 'PUT',
      body: JSON.stringify({ baseRevision, document }),
    })
  )
  return {
    revision: Number(data.revision ?? data.draftRevision) || baseRevision + 1,
    document,
    updatedAt: data.savedAt,
  }
}

export async function patchDraft(projectId: string, baseRevision: number, patch: unknown): Promise<DraftResponse> {
  const data = readData<{
    revision?: number
    draftRevision?: number
    savedAt?: string
    document?: unknown
    draftDocument?: unknown
  }>(
    await apiRequest(`/projects/${projectId}/draft`, {
      method: 'PATCH',
      body: JSON.stringify({ baseRevision, patch }),
    })
  )
  const document = normalizeDoc(data.document ?? data.draftDocument)
  return {
    revision: Number(data.revision ?? data.draftRevision) || baseRevision + 1,
    document: document ?? ({} as Doc),
    updatedAt: data.savedAt,
  }
}
