import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import ProjectsView from '@/views/ProjectsView.vue'
import NewProjectView from '@/views/NewProjectView.vue'
import EditorView from '@/views/EditorView.vue'
import PublicActivityView from '@/views/PublicActivityView.vue'

export const appRoutes: RouteRecordRaw[] = [
  {
    path: '/',
    redirect: '/projects',
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

export default router
