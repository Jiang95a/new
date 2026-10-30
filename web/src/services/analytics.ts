import { apiRequest, readData } from './http'

export interface AnalyticsDay {
  date: string
  submissions: number
  views: number
  count?: number
}

export interface AnalyticsSummary {
  submissions: number
  validSubmissions: number
  pageViews: number
  publishedPages: number
  byDay: AnalyticsDay[]
  byEventType: Record<string, number>
  formStarted: number
  conversionRate: number
}

export interface AnalyticsEvent {
  id: string
  eventType: string
  pageId?: string | null
  metadata?: unknown
  occurredAt: string
}

export interface Pagination {
  page: number
  pageSize: number
  total: number
}

export interface AnalyticsEventPage {
  items: AnalyticsEvent[]
  pagination: Pagination
}

export async function getAnalyticsSummary(projectId: string): Promise<AnalyticsSummary> {
  return readData<AnalyticsSummary>(await apiRequest(`/projects/${projectId}/analytics/summary`))
}

export async function getAnalyticsEvents(
  projectId: string,
  params: { eventType?: string; page?: number; pageSize?: number } = {}
): Promise<AnalyticsEventPage> {
  const search = new URLSearchParams()
  if (params.eventType) search.set('eventType', params.eventType)
  search.set('page', String(params.page ?? 1))
  search.set('pageSize', String(params.pageSize ?? 50))
  const payload = await apiRequest<{
    data?: AnalyticsEvent[]
    pagination?: Pagination
  }>(`/projects/${projectId}/analytics/events?${search.toString()}`)
  return {
    items: Array.isArray(payload.data) ? payload.data : [],
    pagination: payload.pagination ?? {
      page: params.page ?? 1,
      pageSize: params.pageSize ?? 50,
      total: 0,
    },
  }
}
