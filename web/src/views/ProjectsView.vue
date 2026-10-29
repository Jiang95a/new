<script setup lang="ts">
import { RouterLink } from 'vue-router'
import WorkspaceShell from '@/components/studio/WorkspaceShell.vue'
import Icon from '@/components/ui/Icon.vue'
import { useEditorStore } from '@/stores/editor'

const store = useEditorStore()

const stats = [
  { label: '全部项目', value: '6', hint: '2 个正在编辑', icon: 'layers', tone: 'blue' },
  { label: '已发布活动', value: '3', hint: '本月发布 2 个', icon: 'eye', tone: 'green' },
  { label: '累计提交', value: '428', hint: '较上周 +18%', icon: 'users', tone: 'violet' },
  { label: '本周新增', value: '74', hint: '来自 2 个活动', icon: 'chart', tone: 'amber' },
]

const projects = [
  {
    title: store.doc.title,
    type: '社团招新',
    status: '已发布',
    statusTone: 'published',
    submissions: '126 人报名',
    updatedAt: '刚刚更新',
    coverTone: 'photo',
    coverCode: 'PHOTO / 26',
    coverTitle: '寻找校园里的\n下一帧光',
    slug: store.doc.slug,
  },
  {
    title: '校园歌手大赛人气投票',
    type: '投票评选',
    status: '已发布',
    statusTone: 'published',
    submissions: '238 次投票',
    updatedAt: '昨天更新',
    coverTone: 'music',
    coverCode: 'VOICE / LIVE',
    coverTitle: '这一次\n由你来决定',
    slug: 'voice-vote',
  },
  {
    title: '21 天阅读打卡计划',
    type: '每日打卡',
    status: '草稿',
    statusTone: 'draft',
    submissions: '尚未发布',
    updatedAt: '3 天前更新',
    coverTone: 'read',
    coverCode: 'READ / 21',
    coverTitle: '每天读一点\n把世界读厚',
    slug: 'reading-plan',
  },
  {
    title: '迎新志愿者信息收集',
    type: '信息收集',
    status: '已下线',
    statusTone: 'offline',
    submissions: '64 份信息',
    updatedAt: '9 月 18 日',
    coverTone: 'volunteer',
    coverCode: 'VOLUNTEER',
    coverTitle: '一起迎接\n新的同学',
    slug: 'volunteer',
  },
]
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
            <button class="is-active" type="button">全部项目 <span>6</span></button>
            <button type="button">已发布</button>
            <button type="button">草稿</button>
          </div>
          <div class="project-toolbar-actions">
            <button class="project-filter" type="button">最近更新 <Icon name="chevron" :size="13" /></button>
            <button class="app-icon-button" type="button" aria-label="更多筛选">
              <Icon name="sliders" :size="15" />
            </button>
          </div>
        </div>

        <div class="project-grid">
          <article v-for="project in projects" :key="project.title" class="project-card">
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
                  <span />{{ project.status }}
                </span>
                <span>{{ project.submissions }}</span>
              </div>
              <div class="project-card-footer">
                <span>{{ project.updatedAt }}</span>
                <div class="project-card-actions">
                  <RouterLink :to="`/p/${project.slug}`" target="_blank"><Icon name="eye" :size="14" />预览</RouterLink>
                  <RouterLink class="project-edit-link" to="/editor/demo">
                    编辑<Icon name="arrow-right" :size="14" />
                  </RouterLink>
                </div>
              </div>
            </div>
          </article>

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
