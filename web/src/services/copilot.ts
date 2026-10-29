import type { Block, Doc, Issue, Page, Suggestion } from '@/types/editor'
import { contrastRatio, mixColor } from '@/utils/theme'
import { metaOf } from '@/data/blockCatalog'
import { parseDate, uid } from '@/utils/misc'

/**
 * 编辑 Copilot 的本地实现。
 *
 * 智能体连不上时，这一层保证「选中组件 → 至少一条可执行建议」仍然成立（PRD 验收点 4）。
 * 每条都带 before/after，界面必须展示改动前后，由用户点「应用」才写入。
 */

function text(value: unknown): string {
  return typeof value === 'string' ? value : ''
}

/** 2026-11-01 22:00 → 11月1日 22:00（给人看的格式） */
function humanDate(value: string): string {
  const stamp = parseDate(value)
  if (stamp === null) return value
  const date = new Date(stamp)
  const pad = (num: number) => String(num).padStart(2, '0')
  return `${date.getMonth() + 1}月${date.getDate()}日 ${pad(date.getHours())}:${pad(date.getMinutes())}`
}

/** 没选中组件时的页面级建议（也用来兜底） */
function pageSuggestions(doc: Doc, page: Page): Suggestion[] {
  const list: Suggestion[] = []
  const push = (item: Omit<Suggestion, 'id' | 'pageId'>) => {
    list.push({
      ...item,
      // 用「页面 + 组件 + 标题」做稳定 key：重算不换 id，应用过的建议才不会反复冒出来
      id: `sug_page_${page.id}_${item.title}`,
      pageId: page.id,
    })
  }

  const ratio = contrastRatio('#ffffff', doc.theme.primary)
  if (ratio < 4.5) {
    const darker = mixColor(doc.theme.primary, '#111827', 0.3)
    push({
      title: '把主色调深一点',
      reason: `主色上的白字对比度只有 ${ratio.toFixed(1)}:1，投影仪和户外会发灰。`,
      patch: { theme: { primary: darker } },
      before: doc.theme.primary,
      after: darker,
    })
  }

  if (!doc.meta.startAt.trim() || !doc.meta.place.trim()) {
    push({
      title: '时间和地点还没填全',
      reason: '信息卡片、分享海报、二维码落地页都要用到，发布前补上。',
    })
  }

  if (!doc.published) {
    push({
      title: '这页的按钮都指向哪里？',
      reason: '选中按钮，确认「点击后」跳的是报名页，不然报名入口是断的。',
    })
  }

  return list.slice(0, 3)
}

export function suggestFor(doc: Doc, page: Page | undefined, block: Block | undefined): Suggestion[] {
  const list: Suggestion[] = []
  if (!page) return list
  if (!block) return pageSuggestions(doc, page)

  const active = block
  const meta = doc.meta

  const push = (item: Omit<Suggestion, 'id' | 'pageId'>) => {
    list.push({
      ...item,
      id: `sug_block_${page.id}_${active.id}_${item.title}`,
      pageId: page.id,
      // 关键：带上 blockId，store 才知道把 patch 打到哪个组件上
      blockId: item.blockId ?? active.id,
    })
  }

  const props = active.props

  switch (active.type) {
    case 'button': {
      const label = text(props.text).trim()
      if (!label || ['提交', '点击', '确定', '按钮'].includes(label) || label.length > 8) {
        push({
          title: '按钮文案换成明确动作',
          reason: '「提交 / 点击」这类词不告诉人点完会发生什么，改写后点击率会更高。',
          patch: { props: { text: '立即报名' } },
          before: `「${label || '（空）'}」`,
          after: '「立即报名」',
        })
      }
      const action = props.action
      if (!action || action.type === 'none') {
        push({
          title: '给按钮加个去处',
          reason: '现在点了没反应。把它指向报名页，或者设成提交表单。',
          patch: {
            props: { action: { type: 'page', pageId: '', url: '', targetRole: 'form' } },
          },
          before: '无动作',
          after: '跳转到报名页',
        })
      }
      break
    }
    case 'heading': {
      const label = text(props.text).trim()
      if (!label) {
        push({
          title: '给这页补个标题',
          reason: '没有标题，参与者不知道滑到哪儿了。',
          patch: { props: { text: page.name || doc.title } },
          before: '（空）',
          after: page.name || doc.title,
        })
      } else if (label.length > 22) {
        push({
          title: '标题压短一点',
          reason: `${label.length} 个字在手机上会占三四行，第一屏就被占满了。`,
          patch: { props: { text: `${label.slice(0, 16)}…` } },
          before: label,
          after: `${label.slice(0, 16)}…`,
        })
      }
      break
    }
    case 'text': {
      const body = text(props.text)
      if (body.length > 150) {
        const shorter = `${body.slice(0, 120).replace(/\s+$/, '')}…`
        push({
          title: '这段太长了',
          reason: `${body.length} 字，手机一屏最多读 120 字左右。先留最关键的。`,
          patch: { props: { text: shorter } },
          before: `${body.slice(0, 40)}…（${body.length} 字）`,
          after: `${shorter.slice(0, 40)}…（${shorter.length} 字）`,
        })
      }
      break
    }
    case 'banner': {
      if (!text(props.subtitle).trim()) {
        const line = [meta.startAt, meta.place].filter(Boolean).join(' · ')
        if (line) {
          push({
            title: '副标题放上时间和地点',
            reason: '首屏就能看到关键信息，少一次滑动。',
            patch: { props: { subtitle: line } },
            before: '（空）',
            after: line,
          })
        }
      }
      if (!text(props.image).trim()) {
        push({
          title: '换成真实活动照片',
          reason: 'Banner 现在是渐变底，换成海报或现场照更有说服力。',
        })
      }
      break
    }
    case 'form': {
      const fields = Array.isArray(props.fields) ? props.fields : []
      const hasContact = fields.some((field: any) => field.type === 'tel' || field.type === 'email')
      if (!hasContact) {
        const next = [
          ...fields,
          {
            id: uid('f'),
            label: '手机号',
            type: 'tel',
            required: true,
            placeholder: '11 位手机号',
            options: [],
          },
        ]
        push({
          title: '加一个手机号字段',
          reason: '没有联系方式，报名收到了一堆名字也没法通知。',
          patch: { props: { fields: next } },
          before: `${fields.length} 个字段，无联系方式`,
          after: `${next.length} 个字段，含手机号（必填）`,
        })
      }
      if (!fields.some((field: any) => field.required)) {
        push({
          title: '把关键字段设为必填',
          reason: '全都不必填，等于鼓励空提交。',
          patch: {
            props: {
              fields: fields.map((field: any, index: number) => ({
                ...field,
                required: index < 2 ? true : field.required,
              })),
            },
          },
          before: '0 个必填',
          after: `前 ${Math.min(2, fields.length)} 个字段必填`,
        })
      }
      break
    }
    case 'infoCard': {
      const items = Array.isArray(props.items) ? props.items : []
      const pending = items.filter((item: any) => /待补充|待定|TBD/i.test(text(item.value)))
      if (pending.length) {
        push({
          title: '把「待补充」填掉',
          reason: '发布后这几行会原样显示给参与者，很掉分。',
          patch: {
            props: {
              items: items.map((item: any) => {
                if (!/待补充|待定|TBD/i.test(text(item.value))) return item
                if (item.label.includes('时间') && meta.startAt) return { ...item, value: meta.startAt }
                if (item.label.includes('地点') && meta.place) return { ...item, value: meta.place }
                if (item.label.includes('主办') && meta.org) return { ...item, value: meta.org }
                return item
              }),
            },
          },
          before: `${pending.length} 行待补充`,
          after: '用活动信息里的值填上',
        })
      }

      const labels = items.map((item: any) => text(item.label))
      if (!labels.some((label: string) => /截止|截止时间|报名/.test(label)) && meta.deadline) {
        push({
          title: '补一行「报名截止」',
          reason: '信息卡片里没有截止时间，参与者不知道还剩多久。',
          patch: {
            props: {
              items: [
                ...items,
                {
                  id: uid('it'),
                  icon: 'time',
                  label: '报名截止',
                  value: humanDate(meta.deadline),
                },
              ],
            },
          },
          before: `${items.length} 行`,
          after: `${items.length + 1} 行（含报名截止）`,
        })
      } else if (!labels.some((label: string) => /联系|咨询|微信|电话/.test(label)) && meta.contact) {
        push({
          title: '补一行「咨询方式」',
          reason: '有问题找不到人问，是最常见的差评原因。',
          patch: {
            props: {
              items: [...items, { id: uid('it'), icon: 'contact', label: '咨询', value: meta.contact }],
            },
          },
          before: `${items.length} 行`,
          after: `${items.length + 1} 行（含咨询方式）`,
        })
      }
      break
    }
    case 'qrcode': {
      if (!text(props.label).trim()) {
        push({
          title: '给二维码写句说明',
          reason: '光一个码没人知道扫了会发生什么。',
          patch: { props: { label: '扫码查看活动详情' } },
          before: '（空）',
          after: '扫码查看活动详情',
        })
      }
      break
    }
    case 'countdown': {
      if (!text(props.target).trim() && meta.deadline) {
        push({
          title: '倒计时用报名截止时间',
          reason: '和活动信息里的截止时间对齐，避免两个地方对不上。',
          patch: { props: { target: meta.deadline } },
          before: '未设置',
          after: meta.deadline,
        })
      }
      break
    }
    case 'radio':
    case 'checkbox': {
      const options = Array.isArray(props.options) ? props.options : []
      if (options.length > 5) {
        push({
          title: '选项有点多',
          reason: `${options.length} 个选项在手机上要滑两次，能合并就合并。`,
        })
      }
      break
    }
    default:
      break
  }

  // 这一项没有命中任何规则时，退回到「页面级建议」，别编一条假的「没问题」
  if (!list.length) return pageSuggestions(doc, page)

  return list.slice(0, 4)
}

export function localReply(doc: Doc, page: Page | undefined, block: Block | undefined, issues: Issue[]): string {
  const errors = issues.filter((item) => item.level === 'error')
  const warns = issues.filter((item) => item.level === 'warn')
  const parts: string[] = []

  if (block) {
    parts.push(`现在选中的是「${metaOf(block.type).label}」。`)
  } else if (page) {
    parts.push(`现在在「${page.name}」这一页，${page.blocks.length} 个组件。`)
  }

  if (errors.length) {
    parts.push(`**${errors.length} 个必须先修**：${errors[0]?.title}——${errors[0]?.detail}`)
  } else if (warns.length) {
    parts.push(`没有硬伤，但有 ${warns.length} 条建议。最值得改的一条：${warns[0]?.title}。`)
  } else {
    parts.push('当前这版没查出硬性问题，可以发布试试。')
  }

  if (doc.meta.deadline) {
    const stamp = parseDate(doc.meta.deadline)
    if (stamp !== null && stamp < Date.now()) {
      parts.push('提醒一句：报名截止时间已经过了，发布前确认下要不要改。')
    }
  }

  parts.push('（智能体没连上，这段是本地规则给的；连上之后回答会更有针对性。）')
  return parts.join('\n\n')
}

export const QUICK_PROMPTS = [
  '帮我写一段招新文案',
  '这个按钮文案是不是太短了',
  '怎么让首屏更有吸引力',
  '报名表单该收哪些字段',
]
