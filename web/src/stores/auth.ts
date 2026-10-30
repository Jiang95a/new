import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { getMe, login as loginApi, logout as logoutApi, register as registerApi, type AuthUser } from '@/services/auth'
import { getAccessToken, clearTokens } from '@/services/http'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<AuthUser | null>(null)
  const loading = ref(false)
  const error = ref('')

  const isAuthenticated = computed(() => Boolean(getAccessToken()))

  async function login(email: string, password: string): Promise<void> {
    loading.value = true
    error.value = ''
    try {
      const result = await loginApi(email, password)
      user.value = result.user
    } catch (err) {
      error.value = err instanceof Error ? err.message : '登录失败'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function register(email: string, password: string, displayName: string): Promise<void> {
    loading.value = true
    error.value = ''
    try {
      const result = await registerApi(email, password, displayName)
      user.value = result.user
    } catch (err) {
      error.value = err instanceof Error ? err.message : '注册失败'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function fetchMe(): Promise<void> {
    if (!getAccessToken()) return
    try {
      user.value = await getMe()
    } catch {
      clearTokens()
      user.value = null
    }
  }

  async function logout(): Promise<void> {
    try {
      await logoutApi()
    } finally {
      clearTokens()
      user.value = null
    }
  }

  return {
    user,
    loading,
    error,
    isAuthenticated,
    login,
    register,
    fetchMe,
    logout,
  }
})
