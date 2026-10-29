<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import Icon from '@/components/ui/Icon.vue'

const route = useRoute()

const navItems = [
  { href: '/projects', label: '项目工作台', icon: 'home' },
  { href: '/projects/new', label: '新建活动', icon: 'plus' },
  { href: '/projects/new#templates', label: '模板灵感', icon: 'grid' },
  { href: '/editor/demo', label: '页面编辑器', icon: 'layout' },
]

const isActive = computed(() => (href: string) => {
  const path = href.split('#')[0] ?? href
  if (href === '/projects') return route.path === '/projects'
  if (href.includes('#')) return route.hash === `#${href.split('#')[1] ?? ''}`
  return route.path.startsWith(path)
})
</script>

<template>
  <div class="workspace-layout studio-workspace">
    <aside class="workspace-sidebar">
      <RouterLink class="workspace-brand" to="/projects">
        <span class="workspace-brand-mark"><span /><span /></span>
        <span class="workspace-brand-copy">
          <strong>轻搭</strong>
          <small>AI DIY Studio</small>
        </span>
      </RouterLink>

      <div class="workspace-org-card">
        <span class="workspace-org-avatar">学</span>
        <span>
          <strong>学生活动中心</strong>
          <small>团队工作空间</small>
        </span>
        <Icon name="chevron" :size="15" />
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
      </nav>

      <div class="workspace-sidebar-bottom">
        <RouterLink class="workspace-nav-item" to="/projects/new">
          <Icon name="help" :size="17" />
          <span>使用帮助</span>
        </RouterLink>
        <div class="workspace-profile">
          <span class="workspace-profile-avatar">H</span>
          <span>
            <strong>Huiyi</strong>
            <small>活动管理员</small>
          </span>
          <Icon name="sliders" :size="15" />
        </div>
      </div>
    </aside>

    <div class="workspace-main">
      <header class="workspace-topbar">
        <div class="workspace-breadcrumb">
          <span>校园活动</span>
          <span>/</span>
          <strong>{{ route.path.includes('new') ? '新建活动' : '工作台' }}</strong>
        </div>
        <div class="workspace-actions">
          <label class="workspace-search">
            <Icon name="search" :size="16" />
            <input aria-label="搜索项目" placeholder="搜索项目或活动..." />
            <kbd>⌘ K</kbd>
          </label>
          <button class="app-icon-button" type="button" aria-label="通知">
            <Icon name="bell" :size="17" />
          </button>
          <span class="workspace-top-avatar">H</span>
        </div>
      </header>
      <div class="workspace-content"><slot /></div>
    </div>
  </div>
</template>
