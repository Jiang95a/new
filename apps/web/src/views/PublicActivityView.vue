<script setup lang="ts">
import { computed } from 'vue'
import Icon from '@/components/ui/Icon.vue'
import { useEditorStore } from '@/stores/editor'

const store = useEditorStore()
const title = computed(() => store.doc.title || '摄影社 2026 秋季招新')
const org = computed(() => store.doc.meta.org || '光影摄影社')
const startAt = computed(() => store.doc.meta.startAt || '10 月 28 日 18:30')
const place = computed(() => store.doc.meta.place || '大学生活动中心 201')
</script>

<template>
  <main class="activity-page studio-activity">
    <div class="activity-shell">
      <header class="activity-nav">
        <span class="activity-brand"
          ><i><b /><b /></i><span>PHOTO CLUB</span></span
        >
        <button type="button" aria-label="分享活动"><Icon name="external" :size="15" />分享</button>
      </header>

      <section class="activity-hero">
        <div class="activity-hero-orbit activity-hero-orbit--large" />
        <div class="activity-hero-orbit activity-hero-orbit--small" />
        <p>JOIN US · AUTUMN 2026</p>
        <h1>寻找校园里的<br />下一帧光</h1>
        <span>{{ title }}</span>
        <div class="activity-hero-meta"><span>招新截止 · 11 月 01 日</span><span>已有 126 人报名</span></div>
      </section>

      <div class="activity-content">
        <section class="activity-facts">
          <div>
            <span><Icon name="clock" :size="16" /></span><small>活动时间</small><strong>{{ startAt }}</strong>
          </div>
          <div>
            <span><Icon name="pin" :size="16" /></span><small>活动地点</small><strong>{{ place }}</strong>
          </div>
          <div>
            <span><Icon name="users" :size="16" /></span><small>招新对象</small><strong>全校在读学生</strong>
          </div>
        </section>

        <section class="activity-section">
          <p class="activity-kicker">ABOUT US</p>
          <h2>用镜头记录校园的每一种可能</h2>
          <p class="activity-copy">
            从日常街拍到大型活动，从第一次按下快门到独立完成影像项目，我们相信每个人都能找到属于自己的观看方式。
          </p>
          <div class="activity-photo-grid">
            <div class="activity-photo activity-photo--one"><span>01</span><strong>校园日常</strong></div>
            <div class="activity-photo activity-photo--two"><span>02</span><strong>活动记录</strong></div>
            <div class="activity-photo activity-photo--three"><span>03</span><strong>人像实验</strong></div>
          </div>
        </section>

        <section class="activity-section">
          <div class="activity-section-title">
            <div>
              <p class="activity-kicker">DEPARTMENTS</p>
              <h2>找到你的创作位置</h2>
            </div>
            <span>3 个部门</span>
          </div>
          <div class="activity-departments">
            <article>
              <span class="activity-department-number">01</span>
              <div>
                <strong>摄影部</strong>
                <p>负责校园活动、人物与专题影像创作。</p>
              </div>
              <Icon name="arrow-right" :size="17" />
            </article>
            <article>
              <span class="activity-department-number">02</span>
              <div>
                <strong>新媒体部</strong>
                <p>策划图文内容，让一张照片拥有完整叙事。</p>
              </div>
              <Icon name="arrow-right" :size="17" />
            </article>
            <article>
              <span class="activity-department-number">03</span>
              <div>
                <strong>活动部</strong>
                <p>从展览到外拍，把想法变成真正发生的活动。</p>
              </div>
              <Icon name="arrow-right" :size="17" />
            </article>
          </div>
        </section>

        <section id="signup" class="activity-section">
          <p class="activity-kicker">SIGN UP</p>
          <h2>写下你的名字，一起出发</h2>
          <p class="activity-copy">报名后我们会通过短信或邮件发送面试安排，请留意活动信息。</p>
          <div class="activity-form">
            <label><span>姓名 *</span><input placeholder="请输入你的姓名" /></label>
            <div class="activity-form-row">
              <label><span>学号 *</span><input placeholder="例如 20260001" /></label
              ><label><span>手机号 *</span><input placeholder="用于接收面试通知" type="tel" /></label>
            </div>
            <label
              ><span>意向部门 *</span
              ><select>
                <option>请选择一个部门</option>
                <option>摄影部</option>
                <option>新媒体部</option>
                <option>活动部</option>
              </select></label
            >
            <label><span>作品链接</span><input placeholder="选填，可填写相册或社交主页" type="url" /></label>
            <label><span>想对我们说的话</span><textarea placeholder="选填，简单介绍一下你自己" rows="4" /></label>
            <button class="activity-submit" type="button">提交报名<Icon name="arrow-right" :size="15" /></button>
            <small>提交即表示同意活动负责人联系你。</small>
          </div>
        </section>

        <footer class="activity-footer">
          <span>{{ org }} · 2026</span>
          <p>用镜头留下此刻，也留下正在发生的青春。</p>
        </footer>
      </div>

      <div class="activity-sticky-cta">
        <div><small>秋季招新 · 11 月 01 日截止</small><strong>期待与你一起记录校园</strong></div>
        <a href="#signup">立即报名<Icon name="arrow-right" :size="14" /></a>
      </div>
    </div>
  </main>
</template>
