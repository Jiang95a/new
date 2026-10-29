import { ref } from 'vue'

export type ToastKind = 'info' | 'success' | 'warn' | 'error'

export interface ToastItem {
  id: number
  text: string
  kind: ToastKind
}

const items = ref<ToastItem[]>([])
let seq = 0

export function pushToast(text: string, kind: ToastKind = 'info', duration = 2600): number {
  const id = ++seq
  items.value = [...items.value, { id, text, kind }].slice(-4)
  window.setTimeout(() => dismissToast(id), duration)
  return id
}

export function dismissToast(id: number): void {
  items.value = items.value.filter((item) => item.id !== id)
}

export function useToast() {
  return { items, pushToast, dismissToast }
}
