let counter = 0

/** 生成短 id：本地演示够用，接后端之后由后端主导 */
export function uid(prefix = 'b'): string {
  counter = (counter + 1) % 100000
  const random = Math.random().toString(36).slice(2, 7)
  return `${prefix}_${Date.now().toString(36)}${counter.toString(36)}${random}`
}

export function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value))
}

export function debounce<T extends (...args: never[]) => void>(fn: T, wait: number) {
  let timer: number | undefined
  return (...args: Parameters<T>) => {
    if (timer !== undefined) window.clearTimeout(timer)
    timer = window.setTimeout(() => fn(...args), wait)
  }
}

export function formatTime(ts: number): string {
  const date = new Date(ts)
  const hh = `${date.getHours()}`.padStart(2, '0')
  const mm = `${date.getMinutes()}`.padStart(2, '0')
  return `${hh}:${mm}`
}

export function parseDate(value: string): number | null {
  if (!value) return null
  const normalized = value.trim().replace(/\./g, '-').replace(/年|月/g, '-').replace(/日/g, ' ')
  const stamp = Date.parse(normalized)
  return Number.isNaN(stamp) ? null : stamp
}

export function slugify(input: string): string {
  // 只留 ASCII，中文标题最后会变成 p + 随机串；链接短、干净、不会变成一长串 %E5%85%89
  const ascii = input
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 18)
  const suffix = Math.random().toString(36).slice(2, 7)
  return ascii ? `${ascii}-${suffix}` : `p${suffix}`
}
