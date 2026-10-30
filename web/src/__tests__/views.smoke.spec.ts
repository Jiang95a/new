import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import App from '@/App.vue'
import { appRoutes } from '@/router'

const cases = [
  { path: '/projects', selector: '.studio-dashboard', text: '项目工作台' },
  { path: '/projects/new', selector: '.studio-create', text: '把一个想法变成活动页面' },
  { path: '/templates', selector: '.templates-page', text: '模板灵感' },
  { path: '/editor/demo', selector: '.studio-editor', text: '质量检查' },
  // 测试环境无法连接 8080，按“断网才本地兜底”的规则回退到编辑器演示文档。
  // 后端返回 404/未发布时不会再走这个回退。
  { path: '/p/photo-club-2026', selector: '.studio-activity', text: '加入我们，一起搞点事情' },
]

describe('Vue 前端路由冒烟测试', () => {
  it.each(cases)('$path 可以渲染', async ({ path, selector, text }) => {
    localStorage.clear()
    localStorage.setItem('diy-campus:access-token', 'test-token')
    const router = createRouter({
      history: createMemoryHistory(),
      routes: appRoutes,
    })
    await router.push(path)
    await router.isReady()

    const wrapper = mount(App, {
      global: {
        plugins: [createPinia(), router],
      },
    })

    await flushPromises()
    expect(wrapper.find(selector).exists()).toBe(true)
    expect(wrapper.text()).toContain(text)
    wrapper.unmount()
  })
})
