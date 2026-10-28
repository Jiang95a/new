<script setup lang="ts">
import { computed } from 'vue'
import { encode } from 'uqr'

/**
 * 纯前端二维码：uqr 只算矩阵，这里自己拼成 SVG path。
 * 不依赖任何外网图片服务，离线也能用。
 */
const props = withDefaults(
  defineProps<{
    value: string
    size?: number
    ecc?: 'L' | 'M' | 'Q' | 'H'
    quiet?: number
    dark?: string
    light?: string
  }>(),
  { size: 132, ecc: 'M', quiet: 1, dark: '#0f172a', light: 'transparent' }
)

const matrix = computed(() => {
  try {
    return encode(props.value || 'https://campus.local', {
      ecc: props.ecc,
      border: props.quiet,
    })
  } catch {
    return null
  }
})

const path = computed(() => {
  const qr = matrix.value
  if (!qr) return ''
  const parts: string[] = []
  qr.data.forEach((row, y) => {
    let x = 0
    while (x < row.length) {
      if (!row[x]) {
        x += 1
        continue
      }
      let run = 1
      while (x + run < row.length && row[x + run]) run += 1
      parts.push(`M${x} ${y}h${run}v1h-${run}z`)
      x += run
    }
  })
  return parts.join('')
})

const box = computed(() => matrix.value?.size ?? 21)
</script>

<template>
  <svg
    class="qr"
    :width="size"
    :height="size"
    :viewBox="`0 0 ${box} ${box}`"
    shape-rendering="crispEdges"
    role="img"
    aria-label="活动二维码"
  >
    <rect :width="box" :height="box" :fill="light" />
    <path :d="path" :fill="dark" />
  </svg>
</template>

<style scoped>
.qr {
  display: block;
  border-radius: 4px;
}
</style>
