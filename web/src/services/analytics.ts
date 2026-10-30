import { apiRequest, readData } from './http'

export async function getAnalyticsSummary(projectId: string): Promise<unknown> {
  return readData(await apiRequest(`/projects/${projectId}/analytics/summary`))
}

export async function getAnalyticsEvents(projectId: string, page = 1, pageSize = 50): Promise<unknown> {
  return readData(await apiRequest(`/projects/${projectId}/analytics/events?page=${page}&pageSize=${pageSize}`))
}
