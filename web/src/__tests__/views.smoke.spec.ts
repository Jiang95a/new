import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import App from '@/App.vue'
import { appRoutes } from '@/router'

const cases = [
  { path: '/projects', selector: '.studio-dashboard', text: '项目工作台' },
  { path: '/projects/new', selector: '.studio-create', text: '把一个想法变成活动页面' },
  { path: '/editor/demo', selector: '.studio-editor', text: '质量检查' },
  { path: '/p/photo-club-2026', selector: '.studio-activity', text: '寻找校园里的' },
]

describe('Vue 前端路由冒烟测试', () => {
  it.each(cases)('$path 可以渲染', async ({ path, selector, text }) => {
    localStorage.clear()
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
