<script setup lang="ts">
import type { FormField, FieldType } from '@/types/editor'
import Icon from '@/components/ui/Icon.vue'
import { uid } from '@/utils/misc'

const props = defineProps<{ modelValue: FormField[] }>()
const emit = defineEmits<{ 'update:modelValue': [value: FormField[]] }>()

const TYPES: { value: FieldType; label: string }[] = [
  { value: 'text', label: '文本' },
  { value: 'tel', label: '电话' },
  { value: 'email', label: '邮箱' },
  { value: 'textarea', label: '多行文本' },
  { value: 'select', label: '下拉选择' },
  { value: 'radio', label: '单选' },
  { value: 'checkbox', label: '多选' },
]

function patch(index: number, value: Partial<FormField>): void {
  emit(
    'update:modelValue',
    props.modelValue.map((item, itemIndex) => (itemIndex === index ? { ...item, ...value } : item))
  )
}

function remove(index: number): void {
  emit(
    'update:modelValue',
    props.modelValue.filter((_, itemIndex) => itemIndex !== index)
  )
}

function add(): void {
  emit('update:modelValue', [
    ...props.modelValue,
    {
      id: uid('f'),
      label: '新字段',
      type: 'text',
      required: false,
      placeholder: '',
      options: [],
    },
  ])
}

function move(index: number, delta: number): void {
  const target = index + delta
  if (target < 0 || target >= props.modelValue.length) return
  const next = [...props.modelValue]
  const [item] = next.splice(index, 1)
  if (item) next.splice(target, 0, item)
  emit('update:modelValue', next)
}

function onOptions(index: number, event: Event): void {
  const raw = (event.target as HTMLTextAreaElement).value
  patch(index, {
    options: raw
      .split('\n')
      .map((line) => line.trim())
      .filter(Boolean),
  })
}
</script>

<template>
  <div class="fe">
    <div v-for="(field, index) in modelValue" :key="field.id" class="fe__item">
      <div class="fe__row">
        <input
          class="input fe__label"
          :value="field.label"
          placeholder="字段名"
          @input="patch(index, { label: ($event.target as HTMLInputElement).value })"
        />
        <select
          class="select fe__type"
          :value="field.type"
          @change="
            patch(index, {
              type: ($event.target as HTMLSelectElement).value as FieldType,
            })
          "
        >
          <option v-for="type in TYPES" :key="type.value" :value="type.value">
            {{ type.label }}
          </option>
        </select>
        <button
          type="button"
          class="icon-btn icon-btn--sm"
          title="上移"
          :disabled="index === 0"
          @click="move(index, -1)"
        >
          <Icon name="up" :size="11" />
        </button>
        <button
          type="button"
          class="icon-btn icon-btn--sm"
          title="下移"
          :disabled="index === modelValue.length - 1"
          @click="move(index, 1)"
        >
          <Icon name="down" :size="11" />
        </button>
        <button type="button" class="icon-btn icon-btn--sm icon-btn--danger" title="删除" @click="remove(index)">
          <Icon name="trash" :size="11" />
        </button>
      </div>

      <div class="fe__row fe__row--sub">
        <label class="fe__check">
          <input
            type="checkbox"
            :checked="field.required"
            @change="patch(index, { required: ($event.target as HTMLInputElement).checked })"
          />
          必填
        </label>
        <input
          class="input fe__ph"
          :value="field.placeholder"
          placeholder="输入框提示语"
          @input="patch(index, { placeholder: ($event.target as HTMLInputElement).value })"
        />
      </div>

      <textarea
        v-if="field.type === 'select' || field.type === 'radio' || field.type === 'checkbox'"
        class="textarea fe__options"
        rows="2"
        :value="(field.options || []).join('\n')"
        placeholder="选项，每行一个"
        @input="onOptions(index, $event)"
      />
    </div>

    <button type="button" class="btn btn--sm btn--block" @click="add"><Icon name="plus" :size="12" /> 添加字段</button>
  </div>
</template>

<style scoped>
.fe {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.fe__item {
  display: flex;
  flex-direction: column;
  gap: 5px;
  padding: 8px;
  border: 1px solid var(--line);
  border-radius: 10px;
  background: #fcfcfe;
}

.fe__row {
  display: flex;
  align-items: center;
  gap: 4px;
}

.fe__row--sub {
  padding-left: 1px;
}

.fe__label {
  flex: 1;
  min-width: 0;
  height: 28px;
  font-size: 12px;
  padding: 2px 7px;
}

.fe__type {
  width: 84px;
  height: 28px;
  font-size: 11.5px;
  padding: 2px 20px 2px 7px;
}

.fe__check {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 11px;
  color: var(--ink-500);
  white-space: nowrap;
  cursor: pointer;
}

.fe__check input {
  accent-color: var(--brand-600);
  width: 12px;
  height: 12px;
}

.fe__ph {
  height: 26px;
  font-size: 11.5px;
  padding: 2px 7px;
  background: #fff;
}

.fe__options {
  font-size: 11.5px;
  min-height: 46px;
  padding: 5px 7px;
}
</style>
