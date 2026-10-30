<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import Icon from '@/components/ui/Icon.vue'
import AiComposerDrawer from '@/components/ai/AiComposerDrawer.vue'
import { useAiDrawer } from '@/composables/useAiDrawer'
import { useToast } from '@/composables/useToast'
import { useAuthStore } from '@/stores/auth'
import { useProjectStore } from '@/stores/projects'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const projectStore = useProjectStore()
const toast = useToast()
const { openDrawer } = useAiDrawer()
const rootRef = ref<HTMLElement | null>(null)
const searchRef = ref<HTMLInputElement | null>(null)
const searchText = ref('')
const showOrgMenu = ref(false)
const showNotifications = ref(false)
const showUserMenu = ref(false)
const showHelp = ref(false)
const workspaceName = ref('学生活动中心')
const workspaceType = ref('团队工作空间')
const workspaceAvatar = ref('学')

const notifications = [
  { title: '摄影社招新收到 126 份报名', detail: '活动状态正常，报名截止时间为 11 月 1 日', time: '刚刚' },
  { title: '校园歌手投票页面已发布', detail: '可以复制链接或下载二维码分享给同学', time: '2 小时前' },
]

const navItems = [
  { href: '/projects', label: '项目工作台', icon: 'home' },
  { href: '/projects/new', label: '新建活动', icon: 'plus' },
  { href: '/templates', label: '模板灵感', icon: 'grid' },
]

const isActive = computed(() => (href: string) => {
  const path = href.split('#')[0] ?? href
  if (href === '/projects') {
    return route.path === '/projects' || /^\/projects\/[^/]+\/(analytics|submissions|exports)$/.test(route.path)
  }
  if (href.includes('#')) return route.hash === `#${href.split('#')[1] ?? ''}`
  return route.path.startsWith(path)
})

const pageTitle = computed(() => {
  if (route.path === '/projects') return '项目工作台'
  if (route.path === '/projects/new') return '新建活动'
  if (route.path === '/templates') return '模板灵感'
  if (/^\/projects\/[^/]+\/(analytics|submissions|exports)$/.test(route.path)) return '项目数据'
  if (route.path.startsWith('/editor')) return '页面编辑器'
  if (route.path.startsWith('/p/')) return '活动预览'
  return '工作台'
})

/** 左侧栏的「AI 生成」：全局抽屉，任何页面都能开 */
function openAiComposer(): void {
  openDrawer()
}

/**
 * 「页面编辑器」原来硬编码指向 /editor/demo —— demo 早不是真项目 id 了，
 * 点进去后端直接 404。改成「打开最近编辑的项目」，没有项目就引导去新建。
 */
function openLatestEditor(): void {
  const latest = projectStore.projects[0]
  if (!latest) {
    toast.pushToast('还没有项目，先创建一个吧', 'warn')
    void router.push('/projects/new')
    return
  }
  void router.push(`/editor/${latest.id}`)
}

const displayName = computed(() => auth.user?.displayName || 'Huiyi')
const avatarText = computed(() => displayName.value.slice(0, 1).toUpperCase())

async function signOut(): Promise<void> {
  await auth.logout()
  showUserMenu.value = false
  await router.replace('/login')
}

function queryText(): string {
  const value = route.query.q
  return Array.isArray(value) ? (value[0] ?? '') : (value ?? '')
}

watch(
  queryText,
  (value) => {
    searchText.value = value
  },
  { immediate: true }
)

function syncSearch(): void {
  if (route.path !== '/projects') return
  void router.replace({
    path: '/projects',
    query: { ...route.query, q: searchText.value.trim() || undefined },
  })
}

function submitSearch(): void {
  if (route.path !== '/projects') {
    void router.push({
      path: '/projects',
      query: { q: searchText.value.trim() || undefined },
    })
    return
  }
  syncSearch()
}

function clearSearch(): void {
  searchText.value = ''
  syncSearch()
}

function selectWorkspace(name: string, type: string, avatar: string): void {
  workspaceName.value = name
  workspaceType.value = type
  workspaceAvatar.value = avatar
  showOrgMenu.value = false
}

function onDocumentClick(event: MouseEvent): void {
  if (!rootRef.value?.contains(event.target as Node)) {
    showOrgMenu.value = false
    showNotifications.value = false
    showUserMenu.value = false
    showHelp.value = false
  }
}

function onKeydown(event: KeyboardEvent): void {
  if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k') {
    event.preventDefault()
    void nextTick(() => searchRef.value?.focus())
  }
}

onMounted(() => {
  document.addEventListener('mousedown', onDocumentClick)
  window.addEventListener('keydown', onKeydown)
})

onBeforeUnmount(() => {
  document.removeEventListener('mousedown', onDocumentClick)
  window.removeEventListener('keydown', onKeydown)
})
</script>

<template>
  <div ref="rootRef" class="workspace-layout studio-workspace">
    <aside class="workspace-sidebar">
      <RouterLink class="workspace-brand" to="/projects">
        <span class="workspace-brand-mark"><span /><span /></span>
        <span class="workspace-brand-copy">
          <strong>轻搭</strong>
          <small>AI DIY Studio</small>
        </span>
      </RouterLink>

      <div class="workspace-popover-anchor workspace-org-anchor">
        <button
          class="workspace-org-card"
          type="button"
          :aria-expanded="showOrgMenu"
          @click="showOrgMenu = !showOrgMenu"
        >
          <span class="workspace-org-avatar">{{ workspaceAvatar }}</span>
          <span>
            <strong>{{ workspaceName }}</strong>
            <small>{{ workspaceType }}</small>
          </span>
          <Icon name="chevron" :size="15" :class="{ 'is-rotated': showOrgMenu }" />
        </button>
        <div v-if="showOrgMenu" class="workspace-popover workspace-org-menu">
          <p>切换工作空间</p>
          <button type="button" @click="selectWorkspace('学生活动中心', '团队工作空间', '学')">
            <span class="workspace-menu-avatar">学</span>
            <span><strong>学生活动中心</strong><small>8 名团队成员</small></span>
            <Icon v-if="workspaceName === '学生活动中心'" name="check" :size="14" />
          </button>
          <button type="button" @click="selectWorkspace('Huiyi 的个人空间', '个人工作空间', 'H')">
            <span class="workspace-menu-avatar is-personal">H</span>
            <span><strong>Huiyi 的个人空间</strong><small>仅自己可见</small></span>
            <Icon v-if="workspaceName === 'Huiyi 的个人空间'" name="check" :size="14" />
          </button>
          <button class="workspace-menu-footer" type="button" @click="showOrgMenu = false">
            <Icon name="sliders" :size="14" />管理工作空间
          </button>
        </div>
      </div>

      <nav class="workspace-nav" aria-label="工作台导航">
        <span class="workspace-nav-label">工作空间</span>
        <RouterLink
          v-for="item in navItems"
          :key="item.href"
          class="workspace-nav-item"
          :class="{ 'is-active': isActive(item.href) }"
          :to="item.href"
        >
          <Icon :name="item.icon" :size="17" />
          <span>{{ item.label }}</span>
        </RouterLink>
        <button class="workspace-nav-item workspace-nav-item--button is-ai" type="button" @click="openAiComposer">
          <Icon name="wand" :size="17" />
          <span>AI 生成</span>
          <em class="workspace-nav-badge">AI</em>
        </button>
        <button class="workspace-nav-item workspace-nav-item--button" type="button" @click="openLatestEditor">
          <Icon name="layout" :size="17" />
          <span>页面编辑器</span>
        </button>
      </nav>

      <div class="workspace-sidebar-bottom">
        <button class="workspace-nav-item workspace-help-trigger" type="button" @click="showHelp = !showHelp">
          <Icon name="help" :size="17" />
          <span>使用帮助</span>
        </button>
        <div v-if="showHelp" class="workspace-popover workspace-help-popover">
          <strong>快速开始</strong>
          <p>从模板创建活动，在编辑器中修改页面，然后预览并发布。</p>
          <RouterLink to="/projects/new" @click="showHelp = false">新建第一个活动</RouterLink>
        </div>
        <button class="workspace-profile" type="button" @click="showUserMenu = !showUserMenu">
          <span class="workspace-profile-avatar">{{ avatarText }}</span>
          <span>
            <strong>{{ displayName }}</strong>
            <small>活动管理员</small>
          </span>
          <Icon name="sliders" :size="15" />
        </button>
      </div>
    </aside>

    <div class="workspace-main">
      <header class="workspace-topbar">
        <div class="workspace-breadcrumb">
          <RouterLink to="/projects"><Icon name="home" :size="13" />校园活动</RouterLink>
          <span>/</span>
          <strong>{{ pageTitle }}</strong>
        </div>
        <div class="workspace-actions">
          <label class="workspace-search">
            <Icon name="search" :size="16" />
            <input
              ref="searchRef"
              v-model="searchText"
              aria-label="搜索项目"
              placeholder="搜索项目或活动..."
              @input="syncSearch"
              @keydown.enter.prevent="submitSearch"
            />
            <button
              v-if="searchText"
              class="workspace-search-clear"
              type="button"
              aria-label="清空搜索"
              @click="clearSearch"
            >
              <Icon name="close" :size="12" />
            </button>
            <kbd>Ctrl K</kbd>
          </label>
          <div class="workspace-popover-anchor">
            <button
              class="app-icon-button workspace-notification-button"
              type="button"
              aria-label="通知"
              :aria-expanded="showNotifications"
              @click="showNotifications = !showNotifications"
            >
              <Icon name="bell" :size="17" />
              <span class="workspace-notification-dot" />
            </button>
            <div v-if="showNotifications" class="workspace-popover workspace-notification-menu">
              <div class="workspace-popover-heading">
                <strong>通知</strong>
                <span>2 条未读</span>
              </div>
              <button v-for="item in notifications" :key="item.title" type="button" @click="showNotifications = false">
                <span class="workspace-notification-icon"><Icon name="bell" :size="14" /></span>
                <span
                  ><strong>{{ item.title }}</strong
                  ><small>{{ item.detail }}</small
                  ><em>{{ item.time }}</em></span
                >
              </button>
              <button class="workspace-menu-footer" type="button" @click="showNotifications = false">
                查看全部通知
              </button>
            </div>
          </div>
          <div class="workspace-popover-anchor">
            <button
              class="workspace-top-avatar"
              type="button"
              aria-label="账号菜单"
              :aria-expanded="showUserMenu"
              @click="showUserMenu = !showUserMenu"
            >
              {{ avatarText }}
            </button>
            <div v-if="showUserMenu" class="workspace-popover workspace-user-menu">
              <div class="workspace-user-card">
                <span class="workspace-profile-avatar">{{ avatarText }}</span>
                <span
                  ><strong>{{ displayName }}</strong
                  ><small>{{ auth.user?.email || 'huiyi11111 · 前端开发' }}</small></span
                >
              </div>
              <button type="button" @click="showUserMenu = false"><Icon name="users" :size="14" />个人资料</button>
              <button type="button" @click="showUserMenu = false"><Icon name="sliders" :size="14" />偏好设置</button>
              <button type="button" @click="showUserMenu = false"><Icon name="help" :size="14" />帮助与反馈</button>
              <button type="button" @click="signOut"><Icon name="external" :size="14" />退出登录</button>
            </div>
          </div>
        </div>
      </header>
      <div class="workspace-content"><slot /></div>
    </div>

    <AiComposerDrawer />
  </div>
</template>

<style scoped>
/* .workspace-nav-item 原本只服务 <a>，套到 <button> 上会带出浏览器默认的灰底和边框 */
.workspace-nav-item--button {
  width: 100%;
  border: 0;
  background: transparent;
  font: inherit;
  text-align: left;
  cursor: pointer;
}

.workspace-nav-item--button:hover {
  background: var(--ink-50, #f6f7f9);
}

.workspace-nav-item--button.is-ai {
  color: var(--brand-600, #4f46e5);
}

.workspace-nav-badge {
  margin-left: auto;
  padding: 1px 6px;
  border-radius: 999px;
  background: var(--brand-50, #eef2ff);
  color: var(--brand-600, #4f46e5);
  font-size: 9px;
  font-style: normal;
  letter-spacing: 0.04em;
}
</style>
