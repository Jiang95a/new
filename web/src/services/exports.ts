import { apiRequest, readData } from './http'

export interface ExportJob {
  id: string
  status: string
  downloadUrl?: string
}

export async function createExport(projectId: string): Promise<ExportJob> {
  return readData<ExportJob>(await apiRequest(`/projects/${projectId}/exports`, { method: 'POST' }))
}

export async function getExport(id: string): Promise<ExportJob> {
  return readData<ExportJob>(await apiRequest(`/exports/${id}`))
}

export async function getExportDownloadUrl(id: string): Promise<string> {
  const data = await readData<ExportJob | { url?: string }>(await apiRequest(`/exports/${id}/download`))
  return 'url' in data ? (data.url ?? '') : ''
}
