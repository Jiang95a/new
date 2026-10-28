/**
 * 智能体 HTTP 客户端。
 *
 * 后端（agent_first，FastAPI）目前只暴露通用聊天能力：
 *   GET  /health
 *   POST /chat            {message, thread_id?, system_extra?, temperature?}
 *   POST /chat/stream     SSE
 *   GET  /chat/{id}/history
 *
 * 所以页面生成 = 让它按约定吐结构化 JSON，前端再解析成受控组件；
 * 解析不出来就退回文本结构解析，再不行就退回本地模板（见 planner.ts）。
 * 任何一步失败都不能让编辑器卡死——这是硬要求。
 */

const STORAGE_KEY = 'diy-campus:agent-base'
const DEFAULT_BASE = (import.meta.env.VITE_AGENT_BASE_URL as string | undefined) ?? 'http://127.0.0.1:8000'

export type AgentErrorCode = 'OFFLINE' | 'NOT_CONFIGURED' | 'FORMAT' | 'FAILED'

export class AgentError extends Error {
  code: AgentErrorCode
  status?: number

  constructor(code: AgentErrorCode, message: string, status?: number) {
    super(message)
    this.name = 'AgentError'
    this.code = code
    this.status = status
  }
}

export interface AgentHealth {
  ok: boolean
  app?: string
  llm?: Record<string, unknown>
  tools?: string[]
}

export interface AgentToolCall {
  name: string
  result: string
}

export interface AgentReply {
  threadId: string
  reply: string
  latencyMs: number
  toolCalls: AgentToolCall[]
}

export function getAgentBase(): string {
  try {
    return localStorage.getItem(STORAGE_KEY)?.trim() || DEFAULT_BASE
  } catch {
    return DEFAULT_BASE
  }
}

export function setAgentBase(value: string): void {
  try {
    const trimmed = value.trim().replace(/\/+$/, '')
    if (trimmed) localStorage.setItem(STORAGE_KEY, trimmed)
    else localStorage.removeItem(STORAGE_KEY)
  } catch {
    /* 隐私模式下 localStorage 可能不可用，忽略即可 */
  }
}

async function requestJson<T>(path: string, init: RequestInit, timeoutMs: number): Promise<T> {
  const controller = new AbortController()
  const timer = window.setTimeout(() => controller.abort(), timeoutMs)
  let response: Response
  try {
    response = await fetch(`${getAgentBase()}${path}`, {
      ...init,
      signal: controller.signal,
    })
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') {
      throw new AgentError('OFFLINE', '智能体响应超时')
    }
    throw new AgentError('OFFLINE', '连不上智能体服务，请确认后端已启动')
  } finally {
    window.clearTimeout(timer)
  }

  if (response.status === 503) {
    let message = '智能体还没配置模型 Key，暂时只能走本地规则'
    try {
      const body = (await response.json()) as { detail?: { message?: string } }
      if (body.detail?.message) message = body.detail.message
    } catch {
      /* 忽略 */
    }
    throw new AgentError('NOT_CONFIGURED', message, 503)
  }

  if (!response.ok) {
    throw new AgentError('FAILED', `智能体返回 ${response.status}`, response.status)
  }

  try {
    return (await response.json()) as T
  } catch {
    throw new AgentError('FORMAT', '智能体返回的不是合法 JSON')
  }
}

export async function probeAgent(timeoutMs = 1800): Promise<{
  ok: boolean
  health?: AgentHealth
  error?: string
}> {
  try {
    const health = await requestJson<AgentHealth>('/health', { method: 'GET' }, timeoutMs)
    return { ok: Boolean(health?.ok), health }
  } catch (error) {
    const message = error instanceof AgentError ? error.message : '智能体不可用'
    return { ok: false, error: message }
  }
}

export async function askAgent(
  message: string,
  options: { threadId?: string; systemExtra?: string; timeoutMs?: number } = {}
): Promise<AgentReply> {
  const payload: Record<string, unknown> = { message }
  if (options.threadId) payload.thread_id = options.threadId
  if (options.systemExtra) payload.system_extra = options.systemExtra

  const data = await requestJson<{
    thread_id?: string
    reply?: string
    latency_ms?: number
    tool_calls?: { name?: string; result?: string }[]
  }>(
    '/chat',
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    },
    options.timeoutMs ?? 60000
  )

  return {
    threadId: data.thread_id ?? '',
    reply: (data.reply ?? '').trim(),
    latencyMs: data.latency_ms ?? 0,
    toolCalls: (data.tool_calls ?? []).map((item) => ({
      name: item.name ?? '',
      result: item.result ?? '',
    })),
  }
}

/** 从模型回复里把第一个完整的 JSON 对象抠出来（允许前后有解释文字或 ``` 包裹） */
export function extractJson(text: string): unknown | null {
  if (!text) return null
  const cleaned = text.replace(/```json/gi, '```').replace(/```/g, '')
  const start = cleaned.indexOf('{')
  if (start < 0) return null

  let depth = 0
  let inString = false
  let escaped = false

  for (let index = start; index < cleaned.length; index += 1) {
    const char = cleaned[index]
    if (inString) {
      if (escaped) escaped = false
      else if (char === '\\') escaped = true
      else if (char === '"') inString = false
      continue
    }
    if (char === '"') inString = true
    else if (char === '{') depth += 1
    else if (char === '}') {
      depth -= 1
      if (depth === 0) {
        const slice = cleaned.slice(start, index + 1)
        try {
          return JSON.parse(slice) as unknown
        } catch {
          return null
        }
      }
    }
  }
  return null
}

export const PLAN_SYSTEM_EXTRA =
  '本次请求只输出 JSON 对象，不要任何解释、不要 markdown 代码块。JSON 必须符合调用方给出的结构。'
