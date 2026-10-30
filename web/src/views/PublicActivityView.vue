<script setup lang="ts">
import { computed, onMounted, provide, reactive, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import BlockView from '@/components/editor/BlockView.vue'
import Icon from '@/components/ui/Icon.vue'
import { FORM_CONTEXT } from '@/composables/formContext'
import { useToast } from '@/composables/useToast'
import { useEditorStore } from '@/stores/editor'
import { useProjectStore } from '@/stores/projects'
import { themeCssVars } from '@/utils/theme'
import { getPublicActivity, recordPublicEvent, submitForm } from '@/services/public'
import { ApiError } from '@/services/http'
import type { Doc } from '@/types/editor'

const route = useRoute()
const router = useRouter()
const projectStore = useProjectStore()
const editorStore = useEditorStore()
const toast = useToast()
const remoteDocument = ref<Doc | null>(null)
const remoteActivity = ref<{ name: string; slug: string; status: string } | null>(null)
const publicState = ref<'loading' | 'ready' | 'offline' | 'not-found' | 'error'>('loading')
const submitting = ref(false)
const formStartedPages = new Set<string>()

const slug = computed(() => String(route.params.slug ?? ''))
const project = computed(() => projectStore.getBySlug(slug.value))
const fallbackDocument = computed(() => project.value?.document ?? editorStore.doc)
const document = computed(
  () => remoteDocument.value ?? (publicState.value === 'offline' ? fallbackDocument.value : null)
)
const pages = computed(() => document.value?.pages ?? [])
const currentPageId = ref('')
const currentPage = computed(
  () =>
    pages.value.find((page) => page.id === currentPageId.value) ??
    pages.value.find((page) => page.role === 'home') ??
    pages.value[0]
)
const visibleBlocks = computed(() => currentPage.value?.blocks.filter((block) => !block.hidden) ?? [])
const themeVars = computed(() => themeCssVars(document.value?.theme ?? editorStore.doc.theme))
const shareUrl = computed(
  () =>
    project.value?.publicUrl ||
    document.value?.published?.url ||
    `${window.location.origin}/p/${document.value?.slug ?? slug.value}`
)
const unavailable = computed(() => {
  if (publicState.value === 'not-found') {
    return {
      icon: 'file',
      title: '活动不存在或尚未发布',
      text: '请确认分享链接是否正确，或联系活动发布者重新发布。',
    }
  }
  if (publicState.value === 'error') {
    return {
      icon: 'info',
      title: '活动页面加载失败',
      text: '服务暂时没有返回有效内容，请稍后刷新重试。',
    }
  }
  return {
    icon: 'layers',
    title: '正在加载活动',
    text: '正在获取最新发布内容，请稍候。',
  }
})

const answers = reactive<Record<string, string | string[]>>({})
const errors = reactive<Record<string, boolean>>({})

function setAnswer(key: string, value: string | string[]): void {
  answers[key] = value
  if (errors[key]) delete errors[key]
  void recordFormStarted()
}

function recordFormStarted(): void {
  const page = currentPage.value
  if (!page || !page.blocks.some((block) => ['form', 'radio', 'checkbox'].includes(block.type))) return
  if (formStartedPages.has(page.id)) return
  formStartedPages.add(page.id)
  void recordPublicEvent(slug.value, {
    eventType: 'form_started',
    pageId: page.id,
    metadata: { source: 'web' },
  }).catch(() => {
    // 埋点失败不能阻塞表单填写。
  })
}

function clearError(key: string): void {
  if (errors[key]) delete errors[key]
}

provide(FORM_CONTEXT, { answers, errors, setAnswer, clearError })

function resetPage(): void {
  currentPageId.value = pages.value.find((page) => page.role === 'home')?.id ?? pages.value[0]?.id ?? ''
}

watch(document, resetPage, { immediate: true })

onMounted(async () => {
  if (!slug.value) {
    publicState.value = 'not-found'
    return
  }
  try {
    const result = await getPublicActivity(slug.value)
    remoteDocument.value = result.document
    remoteActivity.value = result.activity
    publicState.value = 'ready'
  } catch (error) {
    if (error instanceof ApiError && error.status === 0) {
      // 只有真正断网时才使用本地文档，避免把 404/未发布误显示成本地演示内容。
      publicState.value = 'offline'
    } else if (error instanceof ApiError && (error.status === 404 || error.status === 410)) {
      publicState.value = 'not-found'
    } else {
      publicState.value = 'error'
    }
  }
})

function isEmpty(value: string | string[] | undefined): boolean {
  if (value === undefined) return true
  return Array.isArray(value) ? value.length === 0 : !value.trim()
}

function validate(): boolean {
  let valid = true
  for (const block of currentPage.value?.blocks ?? []) {
    if (block.hidden) continue
    if (block.type === 'form') {
      const fields = Array.isArray(block.props.fields) ? block.props.fields : []
      for (const field of fields) {
        if (!field.required) continue
        const key = `${block.id}:${field.id}`
        if (isEmpty(answers[key])) {
          errors[key] = true
          valid = false
        }
      }
    }
    if ((block.type === 'radio' || block.type === 'checkbox') && block.props.required) {
      if (isEmpty(answers[block.id])) {
        errors[block.id] = true
        valid = false
      }
    }
  }
  return valid
}

async function handleAction(action: any): Promise<void> {
  if (!action) return
  if (action.type === 'url' && action.url) {
    window.open(String(action.url), '_blank', 'noopener')
    return
  }
  if (action.type === 'page') {
    const target =
      pages.value.find((page) => page.id === action.pageId) ??
      pages.value.find((page) => page.role === action.targetRole)
    if (target) currentPageId.value = target.id
    return
  }
  if (action.type === 'submit') {
    if (!validate()) {
      toast.pushToast('请先补全红色标记的必填项', 'warn')
      return
    }
    const formBlock = currentPage.value?.blocks.find((block) => block.type === 'form')
    if (!formBlock || !currentPage.value) {
      toast.pushToast('当前页面没有可提交的表单', 'warn')
      return
    }
    submitting.value = true
    try {
      await submitForm(slug.value, {
        pageId: currentPage.value.id,
        formComponentId: formBlock.id,
        answers,
      })
      const successPage = pages.value.find((page) => page.role === 'success')
      if (successPage) currentPageId.value = successPage.id
      toast.pushToast('报名提交成功', 'success')
    } catch (error) {
      toast.pushToast(error instanceof Error ? error.message : '后端提交失败', 'warn')
    } finally {
      submitting.value = false
    }
  }
}

async function shareActivity(): Promise<void> {
  try {
    if (navigator.share) {
      await navigator.share({ title: document.value?.title ?? '校园活动', url: shareUrl.value })
      return
    }
    await navigator.clipboard.writeText(shareUrl.value)
    toast.pushToast('活动链接已复制', 'success')
  } catch {
    toast.pushToast('分享已取消', 'info')
  }
}

function goBack(): void {
  if (window.history.length > 1) router.back()
  else void router.push('/projects')
}
</script>

<template>
  <main class="activity-page studio-activity">
    <div class="activity-shell public-document-shell" :style="themeVars">
      <header class="activity-nav public-document-nav">
        <div class="activity-nav-left">
          <button class="activity-back" type="button" aria-label="返回上一页" @click="goBack">←</button>
          <span class="activity-brand"
            ><i><b /><b /></i><span>校园活动</span></span
          >
        </div>
        <button type="button" aria-label="分享活动" @click="shareActivity">
          <Icon name="external" :size="15" />分享
        </button>
      </header>

      <div v-if="currentPage" class="public-document-page">
        <BlockView
          v-for="block in visibleBlocks"
          :key="block.id"
          :block="block"
          :theme="document?.theme ?? editorStore.doc.theme"
          :pages="pages"
          :share-url="shareUrl"
          mode="preview"
          @action="handleAction"
        />
      </div>

      <div v-else class="public-document-empty">
        <Icon :name="unavailable.icon" :size="28" />
        <strong>{{ unavailable.title }}</strong>
        <p>{{ unavailable.text }}</p>
        <RouterLink to="/projects">返回项目工作台</RouterLink>
      </div>
    </div>
    <p class="activity-preview-note">
      公开活动 ·
      {{
        remoteActivity?.status === 'published'
          ? '后端已发布'
          : project?.status === 'published'
            ? '本地已发布'
            : '本地预览'
      }}
      <span v-if="submitting"> · 提交中...</span>
    </p>
  </main>
</template>
