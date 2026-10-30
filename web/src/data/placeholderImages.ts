/**
 * 本地占位图：用 SVG 渐变 + 高斯模糊圆生成抽象「照片」。
 *
 * 为什么不直接引外网图：校园活动页常在没有网的教室投影演示，
 * 而且外链图挂了会直接毁掉整个 Banner。这里生成的 data URI 永远可用。
 */

function art(colors: [string, string, string], variant: 'soft' | 'film' | 'grid' = 'soft'): string {
  const [a, b, c] = colors
  const decorations =
    variant === 'film'
      ? `<g opacity=".22" stroke="#fff" stroke-width="1.5">
           <path d="M-40 300 L260 -40" /><path d="M20 360 L340 -20" /><path d="M120 400 L420 20" />
         </g>`
      : variant === 'grid'
        ? `<g opacity=".16" stroke="#fff" stroke-width="1">
             <path d="M0 90h480M0 180h480M0 270h480M120 0v360M240 0v360M360 0v360" />
           </g>`
        : `<g opacity=".18" fill="#fff">
             <circle cx="392" cy="72" r="26" />
             <circle cx="130" cy="300" r="10" />
           </g>`

  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 360" preserveAspectRatio="xMidYMid slice">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${a}"/><stop offset="1" stop-color="${b}"/>
    </linearGradient>
    <filter id="blur" x="-40%" y="-40%" width="180%" height="180%">
      <feGaussianBlur stdDeviation="42"/>
    </filter>
  </defs>
  <rect width="480" height="360" fill="url(#g)"/>
  <g filter="url(#blur)" opacity=".9">
    <circle cx="96" cy="70" r="120" fill="${c}"/>
    <circle cx="402" cy="292" r="150" fill="${b}"/>
    <circle cx="300" cy="40" r="70" fill="${a}"/>
  </g>
  ${decorations}
</svg>`

  return `data:image/svg+xml,${encodeURIComponent(svg)}`
}

export const PLACEHOLDER_IMAGES = {
  dusk: art(['#312e81', '#7c3aed', '#f472b6'], 'soft'),
  dawn: art(['#f59e0b', '#fb7185', '#fde68a'], 'film'),
  forest: art(['#065f46', '#10b981', '#a3e635'], 'grid'),
  ocean: art(['#0c4a6e', '#0284c7', '#67e8f9'], 'soft'),
  ink: art(['#111827', '#334155', '#94a3b8'], 'film'),
  clay: art(['#7c2d12', '#ea580c', '#fcd34d'], 'grid'),
} as const

export type PlaceholderKey = keyof typeof PLACEHOLDER_IMAGES

export function placeholder(key: PlaceholderKey): string {
  return PLACEHOLDER_IMAGES[key]
}
