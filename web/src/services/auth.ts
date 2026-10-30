import { apiRequest, clearTokens, readData, setTokens } from './http'

export interface AuthUser {
  id: string
  displayName: string
  email: string
}

interface AuthPayload {
  accessToken: string
  refreshToken?: string
  user: AuthUser
}

export async function login(email: string, password: string): Promise<AuthPayload> {
  const payload = readData<AuthPayload>(
    await apiRequest(
      '/auth/login',
      {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      },
      { auth: false }
    )
  )
  setTokens(payload.accessToken, payload.refreshToken)
  return payload
}

export async function register(email: string, password: string, displayName: string): Promise<AuthPayload> {
  const payload = readData<AuthPayload>(
    await apiRequest(
      '/auth/register',
      {
        method: 'POST',
        body: JSON.stringify({ email, password, displayName }),
      },
      { auth: false }
    )
  )
  setTokens(payload.accessToken, payload.refreshToken)
  return payload
}

export async function getMe(): Promise<AuthUser> {
  return readData<AuthUser>(await apiRequest('/auth/me'))
}

export async function logout(): Promise<void> {
  try {
    await apiRequest('/auth/logout', { method: 'POST' })
  } finally {
    clearTokens()
  }
}
