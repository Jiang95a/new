const API_BASE = ((import.meta.env.VITE_API_BASE_URL as string | undefined) ?? 'http://127.0.0.1:8080/api/v1').replace(
  /\/+$/,
  ''
)

const ACCESS_KEY = 'diy-campus:access-token'
const REFRESH_KEY = 'diy-campus:refresh-token'

export class ApiError extends Error {
  status: number
  code: string
  details?: unknown
  requestId?: string

  constructor(status: number, code: string, message: string, details?: unknown, requestId?: string) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.code = code
    this.details = details
    this.requestId = requestId
  }
}

export function getAccessToken(): string {
  return localStorage.getItem(ACCESS_KEY) ?? ''
}

export function getRefreshToken(): string {
  return localStorage.getItem(REFRESH_KEY) ?? ''
}

export function setTokens(accessToken: string, refreshToken?: string): void {
  localStorage.setItem(ACCESS_KEY, accessToken)
  if (refreshToken) localStorage.setItem(REFRESH_KEY, refreshToken)
}

export function clearTokens(): void {
  localStorage.removeItem(ACCESS_KEY)
  localStorage.removeItem(REFRESH_KEY)
}

async function parseBody(response: Response): Promise<unknown> {
  const type = response.headers.get('content-type') ?? ''
  if (response.status === 204) return null
  if (type.includes('application/json')) {
    return response.json().catch(() => null)
  }
  return response.text().catch(() => '')
}

async function refreshAccessToken(): Promise<boolean> {
  const refreshToken = getRefreshToken()
  try {
    const response = await fetch(`${API_BASE}/auth/refresh`, {
      method: 'POST',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(refreshToken ? { refreshToken } : {}),
    })
    if (!response.ok) return false
    const payload = (await response.json()) as {
      data?: { accessToken?: string; refreshToken?: string }
      accessToken?: string
      refreshToken?: string
    }
    const data = payload.data ?? payload
    if (!data.accessToken) return false
    setTokens(data.accessToken, data.refreshToken)
    return true
  } catch {
    return false
  }
}

export async function apiRequest<T>(
  path: string,
  init: RequestInit = {},
  options: { auth?: boolean; retryAuth?: boolean; timeoutMs?: number } = {}
): Promise<T> {
  const requiresAuth = options.auth !== false
  const controller = new AbortController()
  const timeout = window.setTimeout(() => controller.abort(), options.timeoutMs ?? 30000)
  const headers = new Headers(init.headers)
  if (!(init.body instanceof FormData) && init.body && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json')
  }
  const token = getAccessToken()
  if (requiresAuth && token) headers.set('Authorization', `Bearer ${token}`)

  let response: Response
  try {
    response = await fetch(`${API_BASE}${path}`, {
      ...init,
      headers,
      credentials: 'include',
      signal: controller.signal,
    })
  } catch (error) {
    const message =
      error instanceof DOMException && error.name === 'AbortError'
        ? '请求超时，请检查后端是否已启动'
        : '无法连接后端服务，请检查 8080 端口'
    throw new ApiError(0, 'NETWORK_ERROR', message)
  } finally {
    window.clearTimeout(timeout)
  }

  if (response.status === 401 && requiresAuth && options.retryAuth !== false) {
    if (await refreshAccessToken()) {
      return apiRequest<T>(path, init, { ...options, retryAuth: false })
    }
    clearTokens()
    window.dispatchEvent(new CustomEvent('auth-expired'))
  }

  const body = await parseBody(response)
  if (!response.ok) {
    const record = body as {
      error?: { code?: string; message?: string; details?: unknown }
      detail?: { code?: string; message?: string }
      message?: string
      requestId?: string
    } | null
    const error = record?.error ?? record?.detail
    throw new ApiError(
      response.status,
      error?.code ?? `HTTP_${response.status}`,
      error?.message ?? record?.message ?? `后端返回 ${response.status}`,
      error && 'details' in error ? error.details : undefined,
      record?.requestId
    )
  }
  return body as T
}

export function readData<T>(payload: unknown): T {
  if (payload && typeof payload === 'object' && 'data' in payload) {
    return (payload as { data: T }).data
  }
  return payload as T
}

export { API_BASE }
