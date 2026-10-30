import { ref, watch } from 'vue'

export type DensityPreference = 'comfortable' | 'compact'
export type MotionPreference = 'full' | 'reduced'
export type LandingPreference = '/projects' | '/templates'

const STORAGE_KEY = 'diy-campus:preferences:v1'

function read<T extends string>(key: string, fallback: T, allowed: readonly T[]): T {
  try {
    const value = localStorage.getItem(`${STORAGE_KEY}:${key}`) as T | null
    return value && allowed.includes(value) ? value : fallback
  } catch {
    return fallback
  }
}

function write(key: string, value: string): void {
  try {
    localStorage.setItem(`${STORAGE_KEY}:${key}`, value)
  } catch {
    // 隐私模式下 localStorage 不可用时只影响本次设备记忆。
  }
}

const density = ref<DensityPreference>(read('density', 'comfortable', ['comfortable', 'compact']))
const motion = ref<MotionPreference>(read('motion', 'full', ['full', 'reduced']))
const landing = ref<LandingPreference>(read('landing', '/projects', ['/projects', '/templates']))

function apply(): void {
  if (typeof document === 'undefined') return
  document.documentElement.dataset.density = density.value
  document.documentElement.dataset.motion = motion.value
}

watch([density, motion], apply, { immediate: true })

export function usePreferences() {
  function setDensity(value: DensityPreference): void {
    density.value = value
    write('density', value)
  }

  function setMotion(value: MotionPreference): void {
    motion.value = value
    write('motion', value)
  }

  function setLanding(value: LandingPreference): void {
    landing.value = value
    write('landing', value)
  }

  function reset(): void {
    setDensity('comfortable')
    setMotion('full')
    setLanding('/projects')
  }

  return { density, motion, landing, setDensity, setMotion, setLanding, reset }
}

export function getLandingPath(): LandingPreference {
  return landing.value
}
