<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import WorkspaceShell from '@/components/studio/WorkspaceShell.vue'
import Icon from '@/components/ui/Icon.vue'
import { useProjectStore, type ProjectStatus } from '@/stores/projects'

const projectStore = useProjectStore()
const route = useRoute()
const router = useRouter()
const statusFilter = ref<'all' | 'published' | 'draft'>('all')
const sortMode = ref<'updated' | 'title'>('updated')

const statusLabels: Record<ProjectStatus, string> = {
  draft: '草稿',
  published: '已发布',
  unpublished: '已下线',
  archived: '已归档',
}

const statusTones: Record<ProjectStatus, string> = {
  draft: 'draft',
  published: 'published',
  unpublished: 'offline',
  archived: 'offline',
}

const projects = computed(() =>
  projectStore.projects.map((project) => ({
    ...project,
    title: project.document.title,
    statusLabel: statusLabels[project.status],
    statusTone: statusTones[project.status],
    submissions: project.submissionCount
      ? `${project.submissionCount} 条提交`
      : project.status === 'published'
        ? '暂无提交'
        : '尚未发布',
    updatedAt: formatProjectDate(project.document.updatedAt),
    slug: project.document.slug,
  }))
)

const stats = computed(() => [
  {
    label: '全部项目',
    value: String(projectStore.projectCount),
    hint: `${projectStore.draftCount} 个正在编辑`,
    icon: 'layers',
    tone: 'blue',
  },
  {
    label: '已发布活动',
    value: String(projectStore.publishedCount),
    hint: '可分享和收集数据',
    icon: 'eye',
    tone: 'green',
  },
  {
    label: '累计提交',
    value: String(projectStore.projects.reduce((sum, project) => sum + project.submissionCount, 0)),
    hint: '全部活动合计',
    icon: 'users',
    tone: 'violet',
  },
  {
    label: '本周新增',
    value: String(
      projectStore.projects.filter((project) => Date.now() - project.document.createdAt < 7 * 86400000).length
    ),
    hint: '最近 7 天创建',
    icon: 'chart',
    tone: 'amber',
  },
])

const rawSearchQuery = computed(() => {
  const value = route.query.q
  return (Array.isArray(value) ? (value[0] ?? '') : (value ?? '')).trim()
})
const searchQuery = computed(() => rawSearchQuery.value.toLowerCase())

const filteredProjects = computed(() => {
  const items = projects.value.filter((project) => {
    const statusMatched =
      statusFilter.value === 'all' ||
      (statusFilter.value === 'published' && project.status === 'published') ||
      (statusFilter.value === 'draft' && project.status === 'draft')
    if (!statusMatched) return false
    if (!searchQuery.value) return true
    const searchable = `${project.title} ${project.type} ${project.statusLabel} ${project.submissions}`.toLowerCase()
    return searchable.includes(searchQuery.value)
  })
  if (sortMode.value === 'title') {
    return [...items].sort((a, b) => a.title.localeCompare(b.title, 'zh-CN'))
  }
  return items
})

const statusCounts = computed(() => ({
  all: projects.value.length,
  published: projects.value.filter((project) => project.status === 'published').length,
  draft: projects.value.filter((project) => project.status === 'draft').length,
}))

function formatProjectDate(timestamp: number): string {
  const diff = Date.now() - timestamp
  if (diff < 60 * 60 * 1000) return '刚刚更新'
  if (diff < 24 * 60 * 60 * 1000) return `${Math.floor(diff / 3600000)} 小时前更新`
  if (diff < 7 * 24 * 60 * 60 * 1000) return `${Math.floor(diff / 86400000)} 天前更新`
  return new Date(timestamp).toLocaleDateString('zh-CN', { month: 'short', day: 'numeric' })
}

function toggleSort(): void {
  sortMode.value = sortMode.value === 'updated' ? 'title' : 'updated'
}

function clearSearch(): void {
  void router.replace({ path: '/projects' })
}
</script>

<template>
  <WorkspaceShell>
    <main class="dashboard-page studio-dashboard">
      <section class="dashboard-heading">
        <div>
          <p class="eyebrow">Workspace</p>
          <h1>项目工作台</h1>
          <p>管理校园活动页面，查看发布状态和报名数据。</p>
        </div>
        <RouterLink class="app-button app-button--primary" to="/projects/new">
          <Icon name="plus" :size="16" />
          新建活动
        </RouterLink>
      </section>

      <section class="stats-grid" id="overview">
        <article v-for="stat in stats" :key="stat.label" class="stat-card">
          <span class="stat-icon" :class="`stat-icon--${stat.tone}`"><Icon :name="stat.icon" :size="17" /></span>
          <div>
            <span class="stat-label">{{ stat.label }}</span>
            <strong>{{ stat.value }}</strong>
            <small>{{ stat.hint }}</small>
          </div>
        </article>
      </section>

      <section class="projects-section">
        <div class="projects-toolbar">
          <div class="project-view-tabs">
            <button :class="{ 'is-active': statusFilter === 'all' }" type="button" @click="statusFilter = 'all'">
              全部项目 <span>{{ statusCounts.all }}</span>
            </button>
            <button
              :class="{ 'is-active': statusFilter === 'published' }"
              type="button"
              @click="statusFilter = 'published'"
            >
              已发布 <span>{{ statusCounts.published }}</span>
            </button>
            <button :class="{ 'is-active': statusFilter === 'draft' }" type="button" @click="statusFilter = 'draft'">
              草稿 <span>{{ statusCounts.draft }}</span>
            </button>
          </div>
          <div class="project-toolbar-actions">
            <button class="project-filter" type="button" @click="toggleSort">
              {{ sortMode === 'updated' ? '最近更新' : '名称排序' }}
              <Icon name="chevron" :size="13" />
            </button>
            <button class="app-icon-button" type="button" aria-label="更多筛选">
              <Icon name="sliders" :size="15" />
            </button>
          </div>
        </div>

        <div v-if="searchQuery" class="project-search-summary">
          <span>搜索“{{ rawSearchQuery }}”，找到 {{ filteredProjects.length }} 个项目</span>
          <button type="button" @click="clearSearch">清除搜索</button>
        </div>

        <div class="project-grid">
          <article v-for="project in filteredProjects" :key="project.title" class="project-card">
            <div class="project-cover" :class="`project-cover--${project.coverTone}`">
              <div class="project-cover-pattern" />
              <span class="project-cover-code">{{ project.coverCode }}</span>
              <strong>{{ project.coverTitle }}</strong>
              <span class="project-cover-dot" />
            </div>
            <div class="project-card-body">
              <div class="project-card-head">
                <div>
                  <span class="project-type">{{ project.type }}</span>
                  <h2>{{ project.title }}</h2>
                </div>
                <button class="project-more" type="button" aria-label="更多操作">
                  <Icon name="more" :size="17" />
                </button>
              </div>
              <div class="project-meta-row">
                <span class="status-pill" :class="`status-pill--${project.statusTone}`">
                  <span />{{ project.statusLabel }}
                </span>
                <span>{{ project.submissions }}</span>
              </div>
              <div class="project-card-footer">
                <span>{{ project.updatedAt }}</span>
                <div class="project-card-actions">
                  <RouterLink :to="`/p/${project.slug}`" target="_blank"><Icon name="eye" :size="14" />预览</RouterLink>
                  <RouterLink class="project-edit-link" :to="`/editor/${project.id}`">
                    编辑<Icon name="arrow-right" :size="14" />
                  </RouterLink>
                </div>
              </div>
            </div>
          </article>

          <div v-if="filteredProjects.length === 0" class="project-empty-state">
            <span><Icon name="search" :size="22" /></span>
            <strong>没有找到匹配的活动</strong>
            <p>尝试换一个关键词，或者清除当前筛选条件。</p>
            <button class="app-button app-button--secondary" type="button" @click="clearSearch">清除搜索</button>
          </div>

          <RouterLink class="project-create-card" to="/projects/new">
            <span class="project-create-icon"><Icon name="plus" :size="21" /></span>
            <strong>创建新的校园活动</strong>
            <p>从模板开始，或者让 AI 根据海报生成。</p>
            <span>开始创建 <Icon name="arrow-right" :size="14" /></span>
          </RouterLink>
        </div>
      </section>
    </main>
  </WorkspaceShell>
</template>
