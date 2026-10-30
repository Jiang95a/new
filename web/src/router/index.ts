import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import ProjectsView from '@/views/ProjectsView.vue'
import NewProjectView from '@/views/NewProjectView.vue'
import EditorView from '@/views/EditorView.vue'
import PublicActivityView from '@/views/PublicActivityView.vue'
import LoginView from '@/views/LoginView.vue'
import { getAccessToken } from '@/services/http'

export const appRoutes: RouteRecordRaw[] = [
  {
    path: '/',
    redirect: '/projects',
  },
  {
    path: '/login',
    name: 'login',
    component: LoginView,
    meta: { public: true },
  },
  {
    path: '/projects',
    name: 'projects',
    component: ProjectsView,
  },
  {
    path: '/projects/new',
    name: 'new-project',
    component: NewProjectView,
  },
  {
    path: '/editor/:projectId',
    name: 'editor',
    component: EditorView,
  },
  {
    path: '/p/:slug',
    name: 'public-activity',
    component: PublicActivityView,
    meta: { public: true },
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/projects',
  },
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: appRoutes,
})

router.beforeEach((to) => {
  if (to.meta.public || to.path === '/login') return true
  if (getAccessToken()) return true
  return {
    path: '/login',
    query: { redirect: to.fullPath },
  }
})

window.addEventListener('auth-expired', () => {
  const current = router.currentRoute.value
  if (current.path === '/login' || current.meta.public) return
  void router.replace({ path: '/login', query: { redirect: current.fullPath } })
})

export default router
