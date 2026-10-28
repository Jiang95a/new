<script setup lang="ts">
import { TEMPLATES } from '@/data/templates'
import Icon from '@/components/ui/Icon.vue'

const emit = defineEmits<{ use: [id: string]; openCreate: [] }>()
</script>

<template>
  <div class="tpl scroll-y">
    <button type="button" class="tpl__ai" @click="emit('openCreate')">
      <span class="tpl__ai-icon"><Icon name="spark" :size="18" /></span>
      <span class="tpl__ai-text">
        <strong>让 AI 从一句话开始</strong>
        <em>说清活动、时间、地点，直接给出四页方案</em>
      </span>
      <Icon name="chevron" :size="14" class="tpl__ai-arrow" />
    </button>

    <p class="tpl__title">
      场景模板<span>{{ TEMPLATES.length }}</span>
    </p>

    <article v-for="template in TEMPLATES" :key="template.id" class="tcard">
      <div
        class="tcard__cover"
        :style="{
          background: `linear-gradient(135deg, ${template.gradient[0]}, ${template.gradient[1]})`,
        }"
      >
        <Icon :name="template.icon" :size="22" />
        <span class="tcard__scene">{{ template.scene }}</span>
      </div>
      <div class="tcard__body">
        <p class="tcard__name">{{ template.name }}</p>
        <p class="tcard__tagline">{{ template.tagline }}</p>
        <button type="button" class="btn btn--sm tcard__btn" @click="emit('use', template.id)">用这个模板</button>
      </div>
    </article>

    <p class="tpl__hint">套用模板会替换当前画布内容，可以用 Ctrl + Z 撤回。</p>
  </div>
</template>

<style scoped>
.tpl {
  height: 100%;
  padding: 14px;
}

.tpl__ai {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  padding: 11px 12px;
  border: 1px solid var(--brand-100);
  border-radius: 13px;
  background: linear-gradient(135deg, var(--brand-50), #f5f3ff);
  text-align: left;
  cursor: pointer;
  transition:
    border-color 0.15s ease,
    transform 0.15s ease;
}

.tpl__ai:hover {
  border-color: var(--brand-300);
  transform: translateY(-1px);
}

.tpl__ai-icon {
  display: grid;
  place-items: center;
  width: 32px;
  height: 32px;
  flex: 0 0 auto;
  border-radius: 10px;
  background: #fff;
  color: var(--brand-600);
  box-shadow: var(--shadow-sm);
}

.tpl__ai-text {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.tpl__ai-text strong {
  font-size: 12.5px;
  color: var(--ink-800);
}

.tpl__ai-text em {
  font-style: normal;
  font-size: 10.5px;
  line-height: 1.5;
  color: var(--ink-500);
}

.tpl__ai-arrow {
  color: var(--brand-400);
  transform: rotate(-90deg);
}

.tpl__title {
  display: flex;
  align-items: center;
  gap: 6px;
  margin: 16px 0 9px;
  font-size: 10.5px;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: var(--ink-400);
}

.tpl__title span {
  padding: 0 5px;
  border-radius: 99px;
  background: var(--ink-100);
}

.tcard {
  overflow: hidden;
  margin-bottom: 10px;
  border: 1px solid var(--line);
  border-radius: 14px;
  background: #fff;
  transition:
    border-color 0.15s ease,
    box-shadow 0.15s ease;
}

.tcard:hover {
  border-color: var(--brand-200);
  box-shadow: 0 10px 26px -20px rgba(79, 70, 229, 0.8);
}

.tcard__cover {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 62px;
  padding: 0 13px;
  color: #fff;
}

.tcard__scene {
  padding: 3px 8px;
  border-radius: 99px;
  background: rgba(255, 255, 255, 0.2);
  font-size: 10px;
  font-weight: 600;
  backdrop-filter: blur(6px);
}

.tcard__body {
  padding: 11px 13px 12px;
}

.tcard__name {
  font-size: 13px;
  font-weight: 700;
  color: var(--ink-800);
}

.tcard__tagline {
  margin-top: 3px;
  font-size: 11px;
  color: var(--ink-500);
}

.tcard__btn {
  width: 100%;
  margin-top: 10px;
}

.tpl__hint {
  margin-top: 4px;
  font-size: 10.5px;
  line-height: 1.6;
  color: var(--ink-400);
}
</style>
