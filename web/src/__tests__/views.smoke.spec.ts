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
  // 注意：测试里 localStorage 是空的，/p/:slug 查不到项目时会回退到编辑器当前文档（demo），
  // 所以这里断言的是 demo 文档里的 Banner 文案，不是种子项目的光影摄影社。
  // 这个回退本身是已知缺陷（换台手机打开分享链接会看到空的/别人的内容），等后端上线要改掉。
  { path: '/p/photo-club-2026', selector: '.studio-activity', text: '加入我们，一起搞点事情' },
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
