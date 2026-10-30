<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import Icon from '@/components/ui/Icon.vue'
import { useAiDrawer } from '@/composables/useAiDrawer'
import { useToast } from '@/composables/useToast'
import { useProjectStore } from '@/stores/projects'
import { askAgent, extractJson, PLAN_SYSTEM_EXTRA, probeAgent } from '@/services/agent'
import { buildPlanPrompt, localDoc, normalizePlan, parsePlanFromText, planToDoc } from '@/services/planner'
import type { Doc, DocPlan } from '@/types/editor'

/**
 * 工作台里的「AI 生成」抽屉。
 *
 * 跟编辑器右侧那个 AiPanel 不是一回事：
 *   AiPanel      —— 有上下文（当前页面、选中组件），回答"这一块怎么改"
 *   AiComposer   —— 没有上下文，负责"从一句话直接生出第一个页面"
 *
 * 生成链路和创建弹窗完全一致（同一套 planner 降级链）：
 *   智能体结构化 JSON → 文本结构解析 → 本地规则兜底
 * 任何一步成功都能落成一份可渲染的 Doc，绝不把用户卡在转圈上。
 */

const router = useRouter()
const toast = useToast()
const projectStore = useProjectStore()
const { open, seed, closeDrawer } = useAiDrawer()

const EXAMPLES = [
  '摄影社 2026 秋季招新，11月8日晚7点在三教402面试，招60人',
  '周五晚上校园荧光夜跑，3公里，报名送手环',
  '校园歌手大赛人气投票，全校师生都能投，每人一票',
  '21 天阅读打卡挑战，每天 24:00 前提交',
]

const prompt = ref('')
const busy = ref(false)
const step = ref('')
const errorText = ref('')
const status = ref<'unknown' | 'online' | 'offline'>('unknown')
const statusLabel = ref('检测中…')
const result = ref<{ doc: Doc; note: string; reason: string; online: boolean } | null>(null)

const textareaRef = ref<HTMLTextAreaElement | null>(null)

const summary = computed(() => {
  if (!result.value) return null
  const doc = result.value.doc
  const blocks = doc.pages.reduce((total, page) => total + page.blocks.length, 0)
  return {
    pages: doc.pages.length,
    blocks,
    title: doc.title,
  }
})

async function refreshStatus(): Promise<void> {
  status.value = 'unknown'
  statusLabel.value = '检测中…'
  const health = await probeAgent(2500)
  if (health.ok) {
    status.value = 'online'
    const model = (health.health?.llm as { model?: string } | undefined)?.model
    statusLabel.value = model ? `在线 · ${model}` : '在线'
  } else {
    status.value = 'offline'
    statusLabel.value = '离线 · 本地规则'
  }
}

watch(open, async (value) => {
  if (!value) return
  prompt.value = seed.value || prompt.value
  result.value = null
  errorText.value = ''
  step.value = ''
  void refreshStatus()
  await nextTick()
  textareaRef.value?.focus()
})

function useExample(text: string): void {
  prompt.value = text
  textareaRef.value?.focus()
}

function guessType(text: string, plan: DocPlan | null): string {
  const haystack = `${text} ${plan?.intent ?? ''}`
  if (/招新|纳新|招募/.test(haystack)) return '社团招新'
  if (/投票|评选|人气/.test(haystack)) return '投票评选'
  if (/打卡|坚持|自律/.test(haystack)) return '每日打卡'
  if (/报名|讲座|比赛|夜跑|分享会/.test(haystack)) return '活动报名'
  return '校园活动'
}

async function generate(): Promise<void> {
  const text = prompt.value.trim()
  if (!text) {
    errorText.value = '先用一句话说清你要办什么活动'
    textareaRef.value?.focus()
    return
  }
  busy.value = true
  errorText.value = ''
  result.value = null

  try {
    if (status.value === 'unknown') await refreshStatus()

    if (status.value === 'online') {
      step.value = '正在让智能体排页面结构…'
      try {
        const reply = await askAgent(buildPlanPrompt(text), { systemExtra: PLAN_SYSTEM_EXTRA })
        const json = extractJson(reply.reply)
        const plan = normalizePlan(json) ?? parsePlanFromText(reply.reply)
        if (plan) {
          const doc = planToDoc(plan)
          const extra: string[] = [`${reply.latencyMs}ms`]
          if (reply.ragHits > 0) extra.push(`资料 ${reply.ragHits} 条`)
          if (reply.toolCalls.length) extra.push(reply.toolCalls.map((call) => call.name).join(' / '))
          result.value = {
            doc,
            note: `${json ? '结构化 JSON' : '文本结构解析'} · ${extra.join(' · ')}`,
            reason: plan.reason || '智能体按需求排好了页面顺序和组件。',
            online: true,
          }
          return
        }
        toast.pushToast('智能体这次没给出页面结构，已用本地规则兜底', 'warn')
      } catch (error) {
        status.value = 'offline'
        const message = error instanceof Error ? error.message : '智能体调用失败'
        toast.pushToast(`${message}，已改用本地规则`, 'warn')
      }
    }

    step.value = '正在按场景匹配模板…'
    const local = localDoc(text)
    result.value = {
      doc: local.doc,
      note: `本地规则 · ${local.scene}模板`,
      reason: local.reason,
      online: false,
    }
  } catch (error) {
    errorText.value = error instanceof Error ? error.message : '生成失败了，重试一次'
  } finally {
    busy.value = false
    step.value = ''
  }
}

async function createFromResult(): Promise<void> {
  if (!result.value || busy.value) return
  busy.value = true
  step.value = '正在创建项目…'
  try {
    const doc = result.value.doc
    const title = doc.title?.trim() || prompt.value.trim().slice(0, 24) || '未命名活动'
    const project = await projectStore.createProjectRemote({
      title,
      type: guessType(prompt.value, null),
      org: doc.meta.org,
      document: doc,
    })
    toast.pushToast('项目已创建，正在打开编辑器', 'success')
    closeDrawer()
    await router.push(`/editor/${project.id}`)
  } catch (error) {
    errorText.value = error instanceof Error ? error.message : '创建项目失败'
  } finally {
    busy.value = false
    step.value = ''
  }
}

function onKeydown(event: KeyboardEvent): void {
  if (!open.value) return
  if (event.key === 'Escape') {
    event.preventDefault()
    closeDrawer()
  }
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onBeforeUnmount(() => window.removeEventListener('keydown', onKeydown))
</script>

<template>
  <Teleport to="body">
    <div v-if="open" class="ai-drawer-mask" @click.self="closeDrawer">
      <aside class="ai-drawer" role="dialog" aria-modal="true" aria-label="AI 生成活动页面">
        <header class="ai-drawer__head">
          <span class="ai-drawer__badge"><Icon name="wand" :size="16" /></span>
          <div class="ai-drawer__titles">
            <strong>AI 生成活动页面</strong>
            <small :class="`ai-drawer__status is-${status}`">
              <i class="dot" />
              {{ statusLabel }}
            </small>
          </div>
          <button class="ai-drawer__close" type="button" aria-label="关闭" @click="closeDrawer">
            <Icon name="close" :size="16" />
          </button>
        </header>

        <div class="ai-drawer__body">
          <p class="ai-drawer__hint">说一句你要办的活动，它直接给你排好页面结构，然后一键建成项目进编辑器改。</p>

          <textarea
            ref="textareaRef"
            v-model="prompt"
            class="ai-drawer__input"
            rows="5"
            placeholder="例如：摄影社 2026 秋季招新，11月8日晚7点在三教402面试，招60人"
            @keydown.ctrl.enter.prevent="generate"
            @keydown.meta.enter.prevent="generate"
          />

          <div class="ai-drawer__examples">
            <button v-for="item in EXAMPLES" :key="item" type="button" @click="useExample(item)">
              {{ item }}
            </button>
          </div>

          <p v-if="errorText" class="ai-drawer__error"><Icon name="alert" :size="13" />{{ errorText }}</p>
          <p v-else-if="step" class="ai-drawer__step"><Icon name="spark" :size="13" />{{ step }}</p>

          <section v-if="result && summary" class="ai-drawer__result">
            <div class="ai-drawer__result-head">
              <strong>{{ summary.title || '生成的页面' }}</strong>
              <span>{{ summary.pages }} 页 · {{ summary.blocks }} 个组件</span>
            </div>
            <p class="ai-drawer__result-reason">{{ result.reason }}</p>
            <p class="ai-drawer__result-note">{{ result.note }}</p>
            <ul class="ai-drawer__pages">
              <li v-for="page in result.doc.pages" :key="page.id">
                <span>{{ page.name }}</span>
                <em>{{ page.blocks.length }} 个组件</em>
              </li>
            </ul>
          </section>
        </div>

        <footer class="ai-drawer__foot">
          <span class="ai-drawer__tip">Ctrl + Enter 生成</span>
          <button class="app-button app-button--secondary" type="button" @click="closeDrawer">取消</button>
          <button
            v-if="!result"
            class="app-button app-button--primary"
            type="button"
            :disabled="busy"
            @click="generate"
          >
            <Icon name="spark" :size="15" />{{ busy ? '生成中…' : '生成页面' }}
          </button>
          <template v-else>
            <button class="app-button app-button--secondary" type="button" :disabled="busy" @click="generate">
              <Icon name="refresh" :size="15" />换一个
            </button>
            <button class="app-button app-button--primary" type="button" :disabled="busy" @click="createFromResult">
              <Icon name="check" :size="15" />{{ busy ? '创建中…' : '创建项目并进入编辑器' }}
            </button>
          </template>
        </footer>
      </aside>
    </div>
  </Teleport>
</template>

<style scoped>
.ai-drawer-mask {
  position: fixed;
  inset: 0;
  z-index: 1200;
  display: flex;
  justify-content: flex-end;
  background: rgba(15, 23, 42, 0.36);
  backdrop-filter: blur(2px);
}

.ai-drawer {
  display: flex;
  flex-direction: column;
  width: min(460px, 100vw);
  height: 100%;
  background: #fff;
  box-shadow: -18px 0 48px rgba(15, 23, 42, 0.18);
  animation: ai-drawer-in 0.18s ease-out;
}

@keyframes ai-drawer-in {
  from {
    transform: translateX(24px);
    opacity: 0.6;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.ai-drawer__head {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 16px 18px;
  border-bottom: 1px solid var(--line-soft, #eef0f6);
}

.ai-drawer__badge {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border-radius: 11px;
  background: var(--brand-50, #eef2ff);
  color: var(--brand-600, #4f46e5);
}

.ai-drawer__titles {
  flex: 1;
  min-width: 0;
}

.ai-drawer__titles strong {
  display: block;
  font-size: 13.5px;
  color: var(--ink-800, #111827);
}

.ai-drawer__status {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  font-size: 10.5px;
  color: var(--ink-400, #98a2b3);
}

.ai-drawer__status .dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--ink-300, #d0d5dd);
}

.ai-drawer__status.is-online .dot {
  background: #12b76a;
}

.ai-drawer__status.is-offline .dot {
  background: #f79009;
}

.ai-drawer__close {
  display: grid;
  place-items: center;
  width: 30px;
  height: 30px;
  border: 0;
  border-radius: 9px;
  background: transparent;
  color: var(--ink-400, #98a2b3);
  cursor: pointer;
}

.ai-drawer__close:hover {
  background: var(--ink-50, #f6f7f9);
  color: var(--ink-700, #344054);
}

.ai-drawer__body {
  flex: 1;
  overflow-y: auto;
  padding: 16px 18px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.ai-drawer__hint {
  margin: 0;
  font-size: 11.5px;
  line-height: 1.7;
  color: var(--ink-500, #667085);
}

.ai-drawer__input {
  width: 100%;
  padding: 11px 12px;
  border: 1px solid var(--line-strong, #e4e7ec);
  border-radius: 11px;
  font: inherit;
  font-size: 12.5px;
  line-height: 1.7;
  color: var(--ink-800, #111827);
  resize: vertical;
  outline: none;
}

.ai-drawer__input:focus {
  border-color: var(--brand-300, #a5b4fc);
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.09);
}

.ai-drawer__examples {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.ai-drawer__examples button {
  max-width: 100%;
  padding: 5px 9px;
  border: 1px dashed var(--line-strong, #e4e7ec);
  border-radius: 8px;
  background: #fff;
  color: var(--ink-500, #667085);
  font-size: 10.5px;
  line-height: 1.5;
  text-align: left;
  cursor: pointer;
}

.ai-drawer__examples button:hover {
  border-color: var(--brand-300, #a5b4fc);
  color: var(--brand-600, #4f46e5);
  background: var(--brand-50, #eef2ff);
}

.ai-drawer__error,
.ai-drawer__step {
  display: flex;
  align-items: center;
  gap: 5px;
  margin: 0;
  padding: 8px 10px;
  border-radius: 9px;
  font-size: 11px;
  line-height: 1.6;
}

.ai-drawer__error {
  background: #fef3f2;
  color: #b42318;
}

.ai-drawer__step {
  background: var(--brand-50, #eef2ff);
  color: var(--brand-700, #3730a3);
}

.ai-drawer__result {
  border: 1px solid var(--line-soft, #eef0f6);
  border-radius: 12px;
  padding: 12px;
  background: var(--ink-50, #f9fafb);
}

.ai-drawer__result-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 8px;
}

.ai-drawer__result-head strong {
  font-size: 12.5px;
  color: var(--ink-800, #111827);
}

.ai-drawer__result-head span {
  flex: 0 0 auto;
  font-size: 10.5px;
  color: var(--ink-400, #98a2b3);
}

.ai-drawer__result-reason {
  margin: 6px 0 0;
  font-size: 11.5px;
  line-height: 1.7;
  color: var(--ink-600, #475467);
}

.ai-drawer__result-note {
  margin: 4px 0 0;
  font-size: 10.5px;
  color: var(--ink-400, #98a2b3);
}

.ai-drawer__pages {
  margin: 10px 0 0;
  padding: 0;
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.ai-drawer__pages li {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: var(--ink-600, #475467);
  padding: 4px 0;
  border-top: 1px dashed var(--line-soft, #eef0f6);
}

.ai-drawer__pages li em {
  font-style: normal;
  color: var(--ink-400, #98a2b3);
}

.ai-drawer__foot {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 18px;
  border-top: 1px solid var(--line-soft, #eef0f6);
}

.ai-drawer__tip {
  flex: 1;
  font-size: 10.5px;
  color: var(--ink-300, #d0d5dd);
}
</style>
