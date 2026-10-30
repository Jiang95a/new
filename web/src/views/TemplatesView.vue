<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import WorkspaceShell from '@/components/studio/WorkspaceShell.vue'
import Icon from '@/components/ui/Icon.vue'
import { TEMPLATES } from '@/data/templates'
import { useAiDrawer } from '@/composables/useAiDrawer'
import { useToast } from '@/composables/useToast'
import { useProjectStore } from '@/stores/projects'

/**
 * 模板灵感页。
 *
 * 之前左侧栏的「模板灵感」指向 /projects/new#templates —— 那只是创建页里的一个
 * 锚点分区，同一个页面内点它，vue-router 不会滚动，表现就是"点了没反应"。
 * 现在给它一条真路由，模板能预览、能一键建成项目。
 *
 * 模板数据目前来自前端 data/templates.ts；后端 GET /templates 通了之后，
 * 这里换成远程列表即可（卡片结构不用动）。
 */

const router = useRouter()
const toast = useToast()
const projectStore = useProjectStore()
const { openDrawer } = useAiDrawer()

const creatingId = ref('')

interface TemplateCard {
  id: string
  name: string
  scene: string
  tagline: string
  icon: string
  gradient: [string, string]
  title: string
  pageCount: number
  blockCount: number
  previewPages: string[]
}

const cards = computed<TemplateCard[]>(() =>
  TEMPLATES.map((template) => {
    const build = template.build()
    return {
      id: template.id,
      name: template.name,
      scene: template.scene,
      tagline: template.tagline,
      icon: template.icon,
      gradient: template.gradient,
      title: build.title,
      pageCount: build.pages.length,
      blockCount: build.pages.reduce((total, page) => total + page.blocks.length, 0),
      previewPages: build.pages.map((page) => page.name),
    }
  })
)

async function useTemplate(card: TemplateCard): Promise<void> {
  if (creatingId.value) return
  creatingId.value = card.id
  try {
    const project = await projectStore.createProjectRemote({
      title: card.title || card.name,
      type: card.name,
      templateId: card.id,
    })
    toast.pushToast(`已按「${card.name}」建好项目，正在打开编辑器`, 'success')
    await router.push(`/editor/${project.id}`)
  } catch (error) {
    toast.pushToast(error instanceof Error ? error.message : '创建失败，稍后再试', 'error')
  } finally {
    creatingId.value = ''
  }
}

function askAi(): void {
  openDrawer()
}
</script>

<template>
  <WorkspaceShell>
    <main class="templates-page">
      <header class="templates-head">
        <div>
          <p class="eyebrow">Templates</p>
          <h1>模板灵感</h1>
          <p class="templates-sub">选一个贴近你活动的结构，进去改文案就行；也可以让 AI 从一句话直接生成。</p>
        </div>
        <button class="app-button app-button--primary" type="button" @click="askAi">
          <Icon name="wand" :size="16" />让 AI 帮我生成
        </button>
      </header>

      <section class="templates-grid">
        <article v-for="card in cards" :key="card.id" class="template-card">
          <div
            class="template-card__art"
            :style="{ background: `linear-gradient(135deg, ${card.gradient[0]}, ${card.gradient[1]})` }"
          >
            <span class="template-card__scene">{{ card.scene }}</span>
            <Icon :name="card.icon || 'grid'" :size="22" />
            <strong>{{ card.name }}</strong>
          </div>
          <div class="template-card__body">
            <h2>{{ card.name }}</h2>
            <p>{{ card.tagline }}</p>
            <ul class="template-card__meta">
              <li>{{ card.pageCount }} 页</li>
              <li>{{ card.blockCount }} 个组件</li>
              <li>{{ card.previewPages.join(' / ') }}</li>
            </ul>
          </div>
          <div class="template-card__foot">
            <span class="template-card__title">示例标题：{{ card.title }}</span>
            <button
              class="app-button app-button--secondary"
              type="button"
              :disabled="creatingId === card.id"
              @click="useTemplate(card)"
            >
              <Icon name="check" :size="15" />
              {{ creatingId === card.id ? '创建中…' : '用这个模板创建' }}
            </button>
          </div>
        </article>
      </section>

      <section class="templates-ai">
        <div>
          <strong>都不太像？</strong>
          <p>直接说一句你要办的活动，AI 会排好页面结构并建成项目。</p>
        </div>
        <button class="app-button app-button--primary" type="button" @click="askAi">
          <Icon name="spark" :size="15" />开始生成
        </button>
      </section>
    </main>
  </WorkspaceShell>
</template>

<style scoped>
.templates-page {
  display: flex;
  flex-direction: column;
  gap: 18px;
  padding: 4px 2px 32px;
}

.templates-head {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
}

.templates-head h1 {
  margin: 2px 0 6px;
  font-size: 22px;
  letter-spacing: -0.2px;
  color: var(--ink-900, #101828);
}

.templates-sub {
  margin: 0;
  font-size: 12.5px;
  color: var(--ink-500, #667085);
}

.templates-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(268px, 1fr));
  gap: 14px;
}

.template-card {
  display: flex;
  flex-direction: column;
  border: 1px solid var(--line-soft, #eef0f6);
  border-radius: 16px;
  background: #fff;
  overflow: hidden;
  transition:
    transform 0.16s ease,
    box-shadow 0.16s ease;
}

.template-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 14px 30px rgba(15, 23, 42, 0.09);
}

.template-card__art {
  position: relative;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  gap: 4px;
  min-height: 112px;
  padding: 14px;
  color: #fff;
}

.template-card__scene {
  position: absolute;
  top: 12px;
  right: 12px;
  font-size: 9.5px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  opacity: 0.78;
}

.template-card__art strong {
  font-size: 15px;
}

.template-card__body {
  flex: 1;
  padding: 12px 14px 8px;
}

.template-card__body h2 {
  margin: 0 0 4px;
  font-size: 13px;
  color: var(--ink-800, #111827);
}

.template-card__body p {
  margin: 0;
  font-size: 11.5px;
  line-height: 1.7;
  color: var(--ink-500, #667085);
}

.template-card__meta {
  margin: 10px 0 0;
  padding: 0;
  list-style: none;
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.template-card__meta li {
  padding: 3px 8px;
  border-radius: 999px;
  background: var(--ink-50, #f6f7f9);
  font-size: 10px;
  color: var(--ink-500, #667085);
}

.template-card__foot {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 10px 14px 14px;
}

.template-card__title {
  font-size: 10.5px;
  color: var(--ink-400, #98a2b3);
}

.templates-ai {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
  padding: 16px 18px;
  border-radius: 16px;
  border: 1px dashed var(--brand-300, #a5b4fc);
  background: var(--brand-50, #eef2ff);
}

.templates-ai strong {
  font-size: 13px;
  color: var(--brand-700, #3730a3);
}

.templates-ai p {
  margin: 4px 0 0;
  font-size: 11.5px;
  color: var(--brand-600, #4f46e5);
}

.eyebrow {
  margin: 0;
  font-size: 10px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--ink-400, #98a2b3);
}
</style>
