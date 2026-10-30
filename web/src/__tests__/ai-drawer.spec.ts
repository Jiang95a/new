import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { beforeEach, describe, expect, it } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import App from '@/App.vue'
import { appRoutes } from '@/router'

/**
 * 这两个功能是「点了有没有反应」型的，光看代码不算数，得真挂载一次：
 *   1. 模板灵感 —— 从死锚点改成真路由，页面上要真有 4 张模板卡
 *   2. AI 生成 —— 左侧栏按钮要能打开抽屉（抽屉 Teleport 到 body，只能去 document 里找）
 */

async function mountAt(path: string) {
  const router = createRouter({ history: createMemoryHistory(), routes: appRoutes })
  await router.push(path)
  await router.isReady()
  const wrapper = mount(App, { global: { plugins: [createPinia(), router] } })
  await flushPromises()
  return wrapper
}

describe('模板灵感与 AI 生成入口', () => {
  beforeEach(() => {
    document.body.innerHTML = ''
    localStorage.clear()
    // 路由守卫要求登录态，这里塞一个假 token 只为过门（不发请求）
    localStorage.setItem('diy-campus:access-token', 'test-token')
  })

  it('模板页渲染 4 张模板卡', async () => {
    const wrapper = await mountAt('/templates')
    expect(wrapper.findAll('.template-card').length).toBe(4)
    expect(wrapper.text()).toContain('用这个模板创建')
    wrapper.unmount()
  })

  it('左侧栏「模板灵感」是真链接，不是死锚点', async () => {
    const wrapper = await mountAt('/projects')
    const hrefs = wrapper.findAll('a.workspace-nav-item').map((node) => node.attributes('href'))
    expect(hrefs).toContain('/templates')
    expect(hrefs.some((href) => String(href).includes('#'))).toBe(false)
    wrapper.unmount()
  })

  it('点「AI 生成」会打开抽屉', async () => {
    const wrapper = await mountAt('/projects')
    expect(document.body.querySelector('.ai-drawer')).toBeNull()

    const buttons = wrapper.findAll('.workspace-nav-item--button')
    expect(buttons.length).toBeGreaterThan(0)
    await buttons[0].trigger('click')
    await flushPromises()

    expect(document.body.querySelector('.ai-drawer')).not.toBeNull()
    expect(document.body.textContent).toContain('AI 生成活动页面')

    const close = document.body.querySelector('.ai-drawer__close') as HTMLButtonElement | null
    close?.click()
    await flushPromises()
    expect(document.body.querySelector('.ai-drawer')).toBeNull()

    wrapper.unmount()
  })
})
