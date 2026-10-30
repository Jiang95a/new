import { ref } from 'vue'

/**
 * AI 生成抽屉的全局开关。
 *
 * 为什么用模块级的 ref 而不是 Pinia store：
 * 这个状态只有一个布尔值 + 一句预填文案，开一个 store 是杀鸡用牛刀。
 * 模块级 ref 在同一个 Vue 应用内天然是单例，组件卸载也不会丢。
 */

const open = ref(false)
const seed = ref('')

export function useAiDrawer() {
  return {
    open,
    seed,
    /** 打开抽屉；传 text 可以预填需求（例如从模板卡片带一句描述进来） */
    openDrawer(text = ''): void {
      seed.value = text
      open.value = true
    },
    closeDrawer(): void {
      open.value = false
    },
  }
}
