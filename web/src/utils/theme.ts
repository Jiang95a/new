import type { Theme } from '@/types/editor'

/** 页面内所有组件都靠这一组 CSS 变量拿主题，换肤不需要重建 DOM */
export function themeCssVars(theme: Theme): Record<string, string> {
  const fontFamily =
    theme.font === 'serif'
      ? 'var(--font-serif)'
      : theme.font === 'round'
        ? '"PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", system-ui, sans-serif'
        : 'var(--font)'

  return {
    '--brand': theme.primary,
    '--accent': theme.accent,
    '--page-bg': theme.bg,
    '--ink': theme.text,
    '--radius': `${theme.radius}px`,
    '--fs': `${theme.fontScale}`,
    '--sp': `${theme.spacing}`,
    '--page-font': fontFamily,
  }
}

export function hexToRgb(hex: string): [number, number, number] | null {
  const value = hex.trim().replace('#', '')
  const full =
    value.length === 3
      ? value
          .split('')
          .map((char) => char + char)
          .join('')
      : value
  if (!/^[0-9a-fA-F]{6}$/.test(full)) return null
  return [parseInt(full.slice(0, 2), 16), parseInt(full.slice(2, 4), 16), parseInt(full.slice(4, 6), 16)]
}

function luminance(hex: string): number | null {
  const rgb = hexToRgb(hex)
  if (!rgb) return null
  const [r, g, b] = rgb.map((channel) => {
    const c = channel / 255
    return c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4
  }) as [number, number, number]
  return 0.2126 * r + 0.7152 * g + 0.0722 * b
}

/** WCAG 对比度，1 ~ 21 */
export function contrastRatio(a: string, b: string): number {
  const la = luminance(a)
  const lb = luminance(b)
  if (la === null || lb === null) return 21
  const light = Math.max(la, lb)
  const dark = Math.min(la, lb)
  return (light + 0.05) / (dark + 0.05)
}

export function isDarkColor(hex: string): boolean {
  const l = luminance(hex)
  return l !== null && l < 0.42
}

/** 往目标色混合，amount 0~1 */
export function mixColor(from: string, to: string, amount: number): string {
  const a = hexToRgb(from)
  const b = hexToRgb(to)
  if (!a || !b) return from
  const mix = a.map((channel, index) => Math.round(channel + ((b[index] ?? channel) - channel) * amount))
  return `#${mix.map((channel) => channel.toString(16).padStart(2, '0')).join('')}`
}

/** 用于深色主题上的卡片底色 */
export function surfaceOf(theme: Theme): string {
  return isDarkColor(theme.bg) ? mixColor(theme.text, theme.bg, 0.88) : '#ffffff'
}

export function mutedOf(theme: Theme): string {
  return isDarkColor(theme.bg) ? mixColor(theme.text, theme.bg, 0.42) : mixColor(theme.text, theme.bg, 0.42)
}
