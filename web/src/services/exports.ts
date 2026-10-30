import { apiRequest, readData } from './http'

export interface ExportJob {
  id: string
  projectId?: string
  status: string
  objectKey?: string | null
  errorMessage?: string | null
  createdAt?: string | null
  finishedAt?: string | null
}

export async function createExport(projectId: string): Promise<ExportJob> {
  return readData<ExportJob>(await apiRequest(`/projects/${projectId}/exports`, { method: 'POST' }))
}

export async function getExport(id: string): Promise<ExportJob> {
  return readData<ExportJob>(await apiRequest(`/exports/${id}`))
}

export async function getExportDownloadUrl(id: string): Promise<string> {
  const data = await readData<{ url?: string }>(await apiRequest(`/exports/${id}/download`))
  return 'url' in data ? (data.url ?? '') : ''
}
