<script setup lang="ts">
import type { InfoItem } from '@/types/editor'
import Icon from '@/components/ui/Icon.vue'
import { INFO_ICON_OPTIONS } from '@/data/blockCatalog'
import { uid } from '@/utils/misc'

const props = defineProps<{ modelValue: InfoItem[] }>()
const emit = defineEmits<{ 'update:modelValue': [value: InfoItem[]] }>()

function patch(index: number, value: Partial<InfoItem>): void {
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
  emit('update:modelValue', [...props.modelValue, { id: uid('it'), icon: 'time', label: '新信息', value: '待补充' }])
}
</script>

<template>
  <div class="ie">
    <div v-for="(item, index) in modelValue" :key="item.id" class="ie__item">
      <div class="ie__row">
        <select
          class="select ie__icon"
          :value="item.icon"
          @change="
            patch(index, {
              icon: ($event.target as HTMLSelectElement).value as InfoItem['icon'],
            })
          "
        >
          <option v-for="option in INFO_ICON_OPTIONS" :key="option.value" :value="option.value">
            {{ option.label }}
          </option>
        </select>
        <input
          class="input ie__label"
          :value="item.label"
          placeholder="名称"
          @input="patch(index, { label: ($event.target as HTMLInputElement).value })"
        />
        <button type="button" class="icon-btn icon-btn--sm icon-btn--danger" @click="remove(index)">
          <Icon name="trash" :size="11" />
        </button>
      </div>
      <input
        class="input ie__value"
        :value="item.value"
        placeholder="内容，例如 三教 402"
        @input="patch(index, { value: ($event.target as HTMLInputElement).value })"
      />
    </div>
    <button type="button" class="btn btn--sm btn--block" @click="add"><Icon name="plus" :size="12" /> 添加一行</button>
  </div>
</template>

<style scoped>
.ie {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.ie__item {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 7px;
  border: 1px solid var(--line);
  border-radius: 10px;
  background: #fcfcfe;
}

.ie__row {
  display: flex;
  align-items: center;
  gap: 4px;
}

.ie__icon {
  width: 68px;
  height: 26px;
  font-size: 11px;
  padding: 2px 18px 2px 6px;
}

.ie__label {
  flex: 1;
  min-width: 0;
  height: 26px;
  font-size: 11.5px;
  padding: 2px 7px;
}

.ie__value {
  height: 26px;
  font-size: 11.5px;
  padding: 2px 7px;
  background: #fff;
}
</style>
