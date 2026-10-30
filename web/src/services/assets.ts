import { apiRequest, readData } from './http'

export interface UploadedAsset {
  assetId: string
  url: string
  mimeType?: string
  width?: number
  height?: number
}

export async function uploadAsset(file: File, projectId?: string): Promise<UploadedAsset> {
  const form = new FormData()
  form.append('file', file)
  if (projectId) form.append('projectId', projectId)
  return readData<UploadedAsset>(await apiRequest('/assets', { method: 'POST', body: form }))
}
