<script setup lang="ts">
import { computed, provide, reactive, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import BlockView from '@/components/editor/BlockView.vue'
import Icon from '@/components/ui/Icon.vue'
import { FORM_CONTEXT } from '@/composables/formContext'
import { useToast } from '@/composables/useToast'
import { useEditorStore } from '@/stores/editor'
import { useProjectStore } from '@/stores/projects'
import { themeCssVars } from '@/utils/theme'

const route = useRoute()
const router = useRouter()
const projectStore = useProjectStore()
const editorStore = useEditorStore()
const toast = useToast()

const project = computed(() => projectStore.getBySlug(String(route.params.slug ?? '')))
const document = computed(() => project.value?.document ?? editorStore.doc)
const pages = computed(() => document.value.pages ?? [])
const currentPageId = ref('')
const currentPage = computed(
  () =>
    pages.value.find((page) => page.id === currentPageId.value) ??
    pages.value.find((page) => page.role === 'home') ??
    pages.value[0]
)
const visibleBlocks = computed(() => currentPage.value?.blocks.filter((block) => !block.hidden) ?? [])
const themeVars = computed(() => themeCssVars(document.value.theme))
const shareUrl = computed(() => document.value.published?.url ?? `${window.location.origin}/p/${document.value.slug}`)

const answers = reactive<Record<string, string | string[]>>({})
const errors = reactive<Record<string, boolean>>({})

function setAnswer(key: string, value: string | string[]): void {
  answers[key] = value
  if (errors[key]) delete errors[key]
}

function clearError(key: string): void {
  if (errors[key]) delete errors[key]
}

provide(FORM_CONTEXT, { answers, errors, setAnswer, clearError })

function resetPage(): void {
  currentPageId.value = pages.value.find((page) => page.role === 'home')?.id ?? pages.value[0]?.id ?? ''
}

watch(document, resetPage, { immediate: true })

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

function handleAction(action: any): void {
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
    const successPage = pages.value.find((page) => page.role === 'success')
    if (successPage) currentPageId.value = successPage.id
    toast.pushToast('提交成功（当前为本地前端演示）', 'success')
  }
}

async function shareActivity(): Promise<void> {
  try {
    if (navigator.share) {
      await navigator.share({ title: document.value.title, url: shareUrl.value })
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
          :theme="document.theme"
          :pages="pages"
          :share-url="shareUrl"
          mode="preview"
          @action="handleAction"
        />
      </div>

      <div v-else class="public-document-empty">
        <Icon name="file" :size="28" />
        <strong>活动页面还没有内容</strong>
        <p>请回到编辑器添加组件并重新发布。</p>
        <RouterLink to="/projects">返回项目工作台</RouterLink>
      </div>
    </div>
    <p class="activity-preview-note">公开活动 · {{ project?.status === 'published' ? '已发布' : '本地预览' }}</p>
  </main>
</template>
