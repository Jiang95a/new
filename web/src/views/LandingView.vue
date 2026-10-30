<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import Icon from '@/components/ui/Icon.vue'
import { getAccessToken } from '@/services/http'

const router = useRouter()
const authenticated = computed(() => Boolean(getAccessToken()))

function startCreating(): void {
  if (authenticated.value) {
    void router.push('/projects/new')
    return
  }
  void router.push({ path: '/login', query: { redirect: '/projects/new' } })
}

function openWorkspace(): void {
  void router.push(authenticated.value ? '/projects' : '/login')
}

function browseCampus(): void {
  void router.push(authenticated.value ? '/campus' : { path: '/login', query: { redirect: '/campus' } })
}
</script>

<template>
  <main class="landing-page">
    <header class="landing-nav">
      <button class="landing-brand" type="button" aria-label="青搭首页" @click="router.push('/')">
        <span class="landing-brand-mark"><i /><i /></span>
        <span><strong>青搭</strong><small>AI DIY STUDIO</small></span>
      </button>
      <nav>
        <a href="#abilities">产品能力</a>
        <a href="#workflow">工作流程</a>
        <button type="button" @click="browseCampus">校园活动</button>
      </nav>
      <div class="landing-nav-actions">
        <button class="landing-login" type="button" @click="openWorkspace">
          {{ authenticated ? '进入工作台' : '登录' }}
        </button>
        <button class="landing-nav-cta" type="button" @click="startCreating">
          免费开始
          <Icon name="arrow-right" :size="14" />
        </button>
      </div>
    </header>

    <section class="landing-hero">
      <div class="landing-hero-glow landing-hero-glow--blue" />
      <div class="landing-hero-glow landing-hero-glow--mint" />
      <div class="landing-hero-copy">
        <span class="landing-kicker"><i />为校园活动而生的 AI 创作工具</span>
        <h1>让校园活动，<br /><em>更快被看见。</em><br />也更容易参与。</h1>
        <p>描述活动需求或上传海报，AI 自动生成页面初稿。继续调整内容与样式，就能发布链接、收集报名、查看真实数据。</p>
        <div class="landing-hero-actions">
          <button class="landing-primary-cta" type="button" @click="startCreating">
            <span><strong>立即做一个活动页</strong><small>无需代码 · 3 分钟开始</small></span>
            <Icon name="arrow-right" :size="19" />
          </button>
          <button class="landing-secondary-cta" type="button" @click="browseCampus">
            <Icon name="pin" :size="16" />
            浏览校园活动
          </button>
        </div>
        <div class="landing-proof">
          <span><b>13</b> 种受控组件</span>
          <span><b>8</b> 步体验检查</span>
          <span><b>0</b> 代码门槛</span>
        </div>
      </div>

      <div class="landing-stage stage-app" aria-label="青搭编辑器界面演示">
        <div class="app-chrome">
          <div class="app-window-dots"><i /><i /><i /></div>
          <span>光影摄影社 · 2026 秋季招新</span>
          <em><i />已保存</em>
        </div>
        <div class="app-shell">
          <aside class="app-sidebar">
            <span>页面</span>
            <b class="is-active"><i />首页</b>
            <b><i />社团介绍</b>
            <b><i />报名表单</b>
            <b><i />报名成功</b>
            <button type="button">＋ 添加页面</button>
          </aside>
          <section class="app-canvas">
            <div class="app-canvas-head">
              <span>手机预览</span>
              <em>390 px</em>
            </div>
            <div class="app-phone">
              <div class="app-phone-nav"><span>光影摄影社</span><i /></div>
              <div class="app-phone-cover">
                <span>JOIN US · 2026</span>
                <strong>寻找校园里的<br />下一帧光</strong>
                <small>秋季招新 · 光影摄影社</small>
              </div>
              <div class="app-phone-copy">
                <span>ABOUT THE CLUB</span>
                <strong>用镜头记录每一种可能</strong>
                <p>每周外拍、每月评片，期末一起办一场展览。</p>
                <div><span>11 月 8 日 19:00</span><span>三教 402</span></div>
                <button type="button">立即报名</button>
              </div>
            </div>
          </section>
          <aside class="app-inspector">
            <span>AI 建议</span>
            <div class="app-ai-note">
              <Icon name="spark" :size="13" />
              <p>主按钮与背景对比度偏低，建议使用深蓝色，保持活动页面的视觉一致性。</p>
            </div>
            <button class="app-adopt" type="button">一键采纳</button>
            <span>组件样式</span>
            <div class="app-style-row"><i />颜色 <b>#1F2937</b></div>
            <div class="app-style-row"><i />圆角 <b>12 px</b></div>
            <div class="app-style-row"><i />字号 <b>16 px</b></div>
          </aside>
        </div>
        <div class="app-ai-bar">
          <span class="app-ai-icon"><Icon name="spark" :size="15" /></span>
          <p>“做一个摄影社招新页，需要社团介绍、部门展示和报名表。”</p>
          <div><span>社团招新</span><span>四页结构</span></div>
          <button type="button">生成页面 <Icon name="arrow-right" :size="13" /></button>
        </div>
      </div>
    </section>

    <div class="landing-marquee" aria-hidden="true">
      <span>AI 生成页面</span><i /> <span>拖拽 DIY</span><i /> <span>活动发布</span><i /> <span>报名收集</span><i />
      <span>数据看板</span><i /> <span>CSV 导出</span>
    </div>

    <section id="abilities" class="landing-section abilities-section">
      <div class="section-heading">
        <span>不只生成一张好看的页面</span>
        <h2>从灵感到真实报名，<br />一条链路全部完成。</h2>
        <p>AI 负责快速起步，你始终保留最后的控制权。</p>
      </div>
      <div class="ability-grid">
        <article class="ability-card ability-card--dark">
          <span class="ability-number">01</span>
          <span class="ability-icon"><Icon name="spark" :size="23" /></span>
          <h3>AI 生成<br />整套页面</h3>
          <p>输入活动需求或上传海报，自动规划首页、介绍、表单和成功页。</p>
          <div class="ability-demo ability-demo--prompt">
            <span>帮我做校园歌手大赛投票页</span>
            <i><b /><b /><b /></i>
          </div>
        </article>
        <article class="ability-card ability-card--cream">
          <span class="ability-number">02</span>
          <span class="ability-icon"><Icon name="cursor" :size="23" /></span>
          <h3>像搭积木<br />一样 DIY</h3>
          <p>拖入组件、调整顺序、换主题色。AI 给建议，点一下采纳。</p>
          <div class="ability-demo ability-demo--blocks"><span /><span /><span /><b>+</b></div>
        </article>
        <article class="ability-card ability-card--mint">
          <span class="ability-number">03</span>
          <span class="ability-icon"><Icon name="chart" :size="23" /></span>
          <h3>发布之后<br />才刚开始</h3>
          <p>二维码分享、表单报名、浏览转化、提交记录和 CSV 导出全部打通。</p>
          <div class="ability-demo ability-demo--chart">
            <i v-for="height in [34, 52, 43, 70, 62, 88]" :key="height" :style="{ height: `${height}%` }" />
          </div>
        </article>
      </div>
    </section>

    <section id="workflow" class="landing-section workflow-section">
      <div class="workflow-intro">
        <span>HOW IT WORKS</span>
        <h2>从活动灵感到报名上线，<br />只需要四步。</h2>
        <button type="button" @click="startCreating">现在试一次 <Icon name="arrow-right" :size="15" /></button>
      </div>
      <div class="workflow-list">
        <article>
          <b>01</b>
          <span><Icon name="spark" :size="18" /></span>
          <div>
            <h3>描述活动</h3>
            <p>说清主题、时间、地点和报名要求。</p>
          </div>
          <em>需求 / 海报</em>
        </article>
        <article>
          <b>02</b>
          <span><Icon name="layout" :size="18" /></span>
          <div>
            <h3>生成并调整</h3>
            <p>AI 给出初稿，你在画布上自由修改。</p>
          </div>
          <em>多页面 DIY</em>
        </article>
        <article>
          <b>03</b>
          <span><Icon name="qr" :size="18" /></span>
          <div>
            <h3>预览并发布</h3>
            <p>检查手机体验，生成链接和二维码。</p>
          </div>
          <em>一键分享</em>
        </article>
        <article>
          <b>04</b>
          <span><Icon name="chart" :size="18" /></span>
          <div>
            <h3>收集与分析</h3>
            <p>查看报名、浏览和转化，导出数据。</p>
          </div>
          <em>真实后端</em>
        </article>
      </div>
    </section>

    <section class="landing-section control-section">
      <div class="control-visual">
        <div class="control-sidebar"><span>页面</span><b>首页</b><b>活动介绍</b><b>报名表单</b><b>成功页</b></div>
        <div class="control-canvas">
          <div class="control-toolbar"><i /><i /><i /></div>
          <div class="control-phone">
            <span>校园 AI 应用分享会</span>
            <strong>三个真实项目，<br />从想法到上线</strong>
            <p>时间 · 地点 · 分享嘉宾</p>
            <button type="button">我要占座</button>
          </div>
          <div class="control-selection">报名按钮 <i /></div>
        </div>
        <div class="control-ai">
          <span><Icon name="spark" :size="14" />AI 建议</span>
          <p>按钮与背景对比度偏低，建议改为深蓝色。</p>
          <button type="button">一键采纳</button>
        </div>
      </div>
      <div class="control-copy">
        <span>YOU STAY IN CONTROL</span>
        <h2>不是“AI 做完你就不能改”。</h2>
        <p>页面结构、文案、图片、颜色和表单都由你掌控。AI 只在合适的时机给建议，每个改动都可以撤销。</p>
        <ul>
          <li><Icon name="check" :size="14" />13 种受控组件，不生成危险 HTML</li>
          <li><Icon name="check" :size="14" />选中组件后给出可执行优化</li>
          <li><Icon name="check" :size="14" />断网或模型不可用时自动本地降级</li>
        </ul>
      </div>
    </section>

    <section class="landing-final-cta">
      <div>
        <span>READY TO CREATE?</span>
        <h2>下一场校园活动，<br />从一个想法开始。</h2>
      </div>
      <button type="button" @click="startCreating">
        创建我的活动页
        <Icon name="arrow-right" :size="18" />
      </button>
      <div class="final-orbit final-orbit--one" />
      <div class="final-orbit final-orbit--two" />
    </section>

    <footer class="landing-footer">
      <div class="landing-brand">
        <span class="landing-brand-mark"><i /><i /></span>
        <span><strong>青搭</strong><small>AI DIY STUDIO</small></span>
      </div>
      <p>让每一个校园想法，都能被看见、被参与。</p>
      <button type="button" @click="openWorkspace">{{ authenticated ? '进入工作台' : '登录工作台' }}</button>
    </footer>
  </main>
</template>
