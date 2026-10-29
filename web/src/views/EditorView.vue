<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { RouterLink, useRoute } from 'vue-router'
import Icon from '@/components/ui/Icon.vue'
import PagesPanel from '@/components/editor/PagesPanel.vue'
import PalettePanel from '@/components/editor/PalettePanel.vue'
import TemplatePanel from '@/components/editor/TemplatePanel.vue'
import InspectorPanel from '@/components/editor/InspectorPanel.vue'
import AiPanel from '@/components/editor/AiPanel.vue'
import PhoneScreen from '@/components/editor/PhoneScreen.vue'
import CreateModal from '@/components/modals/CreateModal.vue'
import PreviewModal from '@/components/modals/PreviewModal.vue'
import PublishModal from '@/components/modals/PublishModal.vue'
import AuditModal from '@/components/modals/AuditModal.vue'
import { useEditorStore } from '@/stores/editor'
import { useProjectStore } from '@/stores/projects'
import { useToast } from '@/composables/useToast'
import { formatTime } from '@/utils/misc'
import type { BlockType, Doc } from '@/types/editor'

type LeftTab = 'pages' | 'components' | 'templates'
type RightTab = 'props' | 'style' | 'ai'
type CreateTab = 'ai' | 'template' | 'poster'

const route = useRoute()
const store = useEditorStore()
const projectStore = useProjectStore()
const toast = useToast()
const { doc, currentPage, blockCount, saving, savedAt, canUndo, canRedo, issueSummary } = storeToRefs(store)

const leftTab = ref<LeftTab>('pages')
const rightTab = ref<RightTab>('props')
const createOpen = ref(false)
const createTab = ref<CreateTab>('ai')
const previewOpen = ref(false)
const publishOpen = ref(false)
const auditOpen = ref(false)
const deviceWidth = ref(390)
const activeProjectId = ref('')
let syncReady = false

const requestedProjectId = computed(() => String(route.params.projectId ?? ''))

function loadRequestedProject(): void {
  const project =
    projectStore.getById(requestedProjectId.value) ??
    projectStore.getBySlug(requestedProjectId.value) ??
    projectStore.projects[0]
  if (!project) return
  activeProjectId.value = project.id
  store.loadDocument(project.id, project.document)
  syncReady = true
}

watch(requestedProjectId, loadRequestedProject, { immediate: true })

watch(
  doc,
  (value) => {
    if (!syncReady || !activeProjectId.value) return
    projectStore.saveDocument(activeProjectId.value, value)
    const project = projectStore.getById(activeProjectId.value)
    if (!project) return
    if (value.published && project.status !== 'published') {
      projectStore.publishProject(activeProjectId.value, value.published.url, value.published.slug)
    } else if (!value.published && project.status === 'published') {
      projectStore.unpublishProject(activeProjectId.value)
    }
  },
  { deep: true }
)

const saveLabel = computed(() => {
  if (saving.value) return '保存中...'
  if (savedAt.value) return `已保存 ${formatTime(savedAt.value)}`
  return '未保存'
})

function openCreate(tab: CreateTab = 'ai'): void {
  createTab.value = tab
  createOpen.value = true
}

function onApplied(next: Doc): void {
  store.applyDoc(next, true)
  createOpen.value = false
  toast.pushToast(`已应用「${next.title}」，可以继续编辑`, 'success')
}

function useTemplate(id: string): void {
  store.useTemplate(id)
  toast.pushToast('模板已套用，所有修改可以撤销', 'success')
}

function requestPalette(): void {
  leftTab.value = 'components'
}

function onTitleInput(event: Event): void {
  store.updateTitle((event.target as HTMLInputElement).value)
}

function onKeydown(event: KeyboardEvent): void {
  const target = event.target as HTMLElement | null
  const inField = target?.tagName === 'INPUT' || target?.tagName === 'TEXTAREA' || target?.tagName === 'SELECT'
  const meta = event.ctrlKey || event.metaKey
  if (!meta || inField) return
  if (event.key.toLowerCase() === 'z') {
    event.preventDefault()
    if (event.shiftKey) store.redo()
    else store.undo()
  }
  if (event.key.toLowerCase() === 'y') {
    event.preventDefault()
    store.redo()
  }
  if (event.key.toLowerCase() === 's') {
    event.preventDefault()
    store.saveNow()
    toast.pushToast('已保存到本地', 'success')
  }
}

onMounted(() => {
  window.addEventListener('keydown', onKeydown)
  if (route.query.create === 'ai' || route.query.create === 'poster' || route.query.create === 'template') {
    openCreate(route.query.create)
  }
})

onBeforeUnmount(() => window.removeEventListener('keydown', onKeydown))
</script>

<template>
  <main class="editor-shell studio-editor">
    <header class="editor-topbar">
      <div class="editor-project-area">
        <RouterLink class="editor-back-link" to="/projects">
          <span>←</span>
          工作台
        </RouterLink>
        <RouterLink class="editor-logo" to="/projects" aria-label="返回工作台"
          ><span><i /><i /></span
        ></RouterLink>
        <div class="editor-project-copy">
          <input :value="doc.title" aria-label="活动名称" @input="onTitleInput" />
          <span><i />{{ saveLabel }}</span>
        </div>
        <button class="editor-project-more" type="button" aria-label="AI 创建" @click="openCreate('ai')">
          <Icon name="wand" :size="16" />
        </button>
      </div>

      <div class="editor-history">
        <button type="button" :disabled="!canUndo" aria-label="撤销" @click="store.undo()">
          <Icon name="undo" :size="16" />
        </button>
        <button type="button" :disabled="!canRedo" aria-label="重做" @click="store.redo()">
          <Icon name="redo" :size="16" />
        </button>
      </div>

      <div class="editor-top-actions">
        <button class="editor-preview-link" type="button" @click="auditOpen = true">
          <Icon name="check-circle" :size="15" />质量检查
        </button>
        <button class="editor-preview-link" type="button" @click="openCreate('poster')">
          <Icon name="image" :size="15" />海报
        </button>
        <button class="editor-preview-link" type="button" @click="previewOpen = true">
          <Icon name="eye" :size="15" />预览
        </button>
        <button class="app-button app-button--primary editor-publish-button" type="button" @click="publishOpen = true">
          发布
        </button>
      </div>
    </header>

    <div class="editor-layout">
      <aside class="editor-left">
        <div class="editor-side-tabs">
          <button type="button" :class="{ 'is-active': leftTab === 'pages' }" @click="leftTab = 'pages'">页面</button>
          <button type="button" :class="{ 'is-active': leftTab === 'components' }" @click="leftTab = 'components'">
            组件
          </button>
          <button type="button" :class="{ 'is-active': leftTab === 'templates' }" @click="leftTab = 'templates'">
            模板
          </button>
        </div>
        <div class="editor-studio-panel">
          <PagesPanel v-if="leftTab === 'pages'" />
          <PalettePanel v-else-if="leftTab === 'components'" @add="store.addBlock($event as BlockType)" />
          <TemplatePanel v-else @use="useTemplate" @open-create="openCreate('template')" />
        </div>
      </aside>

      <section class="editor-workspace">
        <div class="editor-canvas-toolbar">
          <span><i />{{ currentPage?.name }} · {{ currentPage?.blocks.length }} 个组件</span>
          <div class="studio-device-tabs">
            <button
              v-for="width in [375, 390, 430]"
              :key="width"
              type="button"
              :class="{ 'is-active': deviceWidth === width }"
              @click="deviceWidth = width"
            >
              {{ width }}
            </button>
          </div>
        </div>
        <div class="editor-canvas-stage studio-editor-stage">
          <PhoneScreen
            v-if="currentPage"
            :page="currentPage"
            :theme="doc.theme"
            :pages="doc.pages"
            :share-url="store.shareUrl"
            :selected-id="store.selectedBlockId"
            :width="deviceWidth"
            mode="edit"
            @select="store.selectBlock"
            @insert="(type, index) => store.addBlock(type, index)"
            @move="(id, index) => store.moveBlock(id, index)"
            @move-by="(id, delta) => store.moveBlockBy(id, delta)"
            @remove="store.removeBlock"
            @duplicate="store.duplicateBlock"
            @toggle-hidden="store.toggleHidden"
            @request-palette="requestPalette"
          />
        </div>
        <div class="editor-statusbar">
          <span><i class="status-dot status-dot--green" />{{ doc.pages.length }} 页 · {{ blockCount }} 个组件</span>
          <span
            >{{
              issueSummary.error
                ? `${issueSummary.error} 个错误`
                : issueSummary.warn
                  ? `${issueSummary.warn} 条建议`
                  : '检查通过'
            }}
            · {{ doc.published ? '已发布' : '草稿' }}</span
          >
        </div>
      </section>

      <aside class="editor-right">
        <div class="editor-inspector-tabs">
          <button type="button" :class="{ 'is-active': rightTab === 'props' }" @click="rightTab = 'props'">属性</button>
          <button type="button" :class="{ 'is-active': rightTab === 'style' }" @click="rightTab = 'style'">样式</button>
          <button type="button" :class="{ 'is-active': rightTab === 'ai' }" @click="rightTab = 'ai'">
            <Icon name="spark" :size="13" />AI 建议
          </button>
        </div>
        <div class="editor-studio-panel editor-studio-panel--right">
          <InspectorPanel v-show="rightTab !== 'ai'" :tab="rightTab === 'style' ? 'style' : 'props'" />
          <AiPanel v-show="rightTab === 'ai'" @generate="openCreate('ai')" />
        </div>
      </aside>
    </div>

    <CreateModal :open="createOpen" :initial-tab="createTab" @close="createOpen = false" @applied="onApplied" />
    <PreviewModal :open="previewOpen" @close="previewOpen = false" />
    <PublishModal :open="publishOpen" @close="publishOpen = false" />
    <AuditModal :open="auditOpen" @close="auditOpen = false" />
  </main>
</template>
