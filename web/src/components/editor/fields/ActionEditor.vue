<script setup lang="ts">
import type { ButtonAction, Page } from '@/types/editor'

const props = defineProps<{ modelValue: ButtonAction; pages: Page[] }>()
const emit = defineEmits<{ 'update:modelValue': [value: ButtonAction] }>()

function patch(value: Partial<ButtonAction>): void {
  emit('update:modelValue', { ...props.modelValue, ...value })
}
</script>

<template>
  <div class="ae">
    <select
      class="select"
      :value="modelValue?.type ?? 'page'"
      @change="
        patch({
          type: ($event.target as HTMLSelectElement).value as ButtonAction['type'],
        })
      "
    >
      <option value="page">跳转到页面</option>
      <option value="submit">提交表单</option>
      <option value="url">打开链接</option>
      <option value="none">无动作</option>
    </select>

    <select
      v-if="modelValue?.type === 'page'"
      class="select"
      :value="modelValue.pageId"
      @change="patch({ pageId: ($event.target as HTMLSelectElement).value })"
    >
      <option value="">选择目标页面…</option>
      <option v-for="page in pages" :key="page.id" :value="page.id">
        {{ page.name }}
      </option>
    </select>

    <input
      v-if="modelValue?.type === 'url'"
      class="input"
      :value="modelValue.url"
      placeholder="https://…"
      @input="patch({ url: ($event.target as HTMLInputElement).value })"
    />

    <p v-if="modelValue?.type === 'submit'" class="hint">点下去就校验并提交本页表单，提交成功后自动跳到「成功页」。</p>
  </div>
</template>

<style scoped>
.ae {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
</style>
