import { apiRequest, readData } from './http'

export interface PublishResult {
  publicSlug: string
  publicUrl: string
  publishedVersionId?: string
  publishedAt?: string
}

export async function publishProject(id: string, slug?: string): Promise<PublishResult> {
  // slug 为空时整个字段都不发：JSON.stringify 会把 undefined 的键直接删掉，
  // 后端才能走「按标题自动生成」的分支。
  return readData<PublishResult>(
    await apiRequest(`/projects/${id}/publish`, {
      method: 'POST',
      body: JSON.stringify(slug ? { slug } : {}),
    })
  )
}

export async function unpublishProject(id: string): Promise<void> {
  await apiRequest(`/projects/${id}/unpublish`, { method: 'POST' })
}

export async function listVersions(id: string): Promise<unknown[]> {
  const data = readData<unknown>(await apiRequest(`/projects/${id}/versions`))
  return Array.isArray(data) ? data : []
}
