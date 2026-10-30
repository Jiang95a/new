-- ============================================================================
-- 003_seed_fix.sql —— 修 002_seed.sql 里三个「演示当场会炸」的问题
--
-- 为什么单独一个文件：002 是别人写的，直接改会和后续 pull 冲突；
-- 这里用幂等 SQL 覆盖掉坏数据，可重复执行。
--
--   1) 演示用户 password_hash 是占位串（不是合法 BCrypt）-> 登录必然失败
--      这里换成真 hash，密码：Campus2026a
--   2) 模板 document 里的组件属性名和前端受控组件对不上
--      submitText -> buttonText、caption -> label、button 缺 action、infoCard 缺 items
--      -> 按 web/src/data/blockCatalog.ts 逐字对齐
--   3) 演示项目 draft_document.pages 是空数组 -> 打开是空白编辑器
--      -> 塞一份完整的四页文档
--
-- 执行：
--   mysql -u root campus_diy -e "source docs/sql/003_seed_fix.sql"
-- ============================================================================

SET NAMES utf8mb4;

-- ---------------------------------------------------------------- 1) 演示用户

INSERT INTO users (id, email, password_hash, display_name, status)
VALUES ('00000000-0000-4000-8000-000000000001', 'demo@example.com', '$2b$10$Do1W6S0EmK4T4r7uCTctWudHZe/Saag9z610FjHe9t8nMfM4IUJ5m', '演示同学', 'active')
ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash),
                        display_name = VALUES(display_name),
                        status = 'active';

-- ---------------------------------------------------------------- 2) 四个模板

INSERT INTO templates (id, code, name, category, description, cover_url, document, is_active)
VALUES ('00000000-0000-4000-8000-000000000101', 'recruitment-club', '社团招新', 'recruitment', '首页 + 社团介绍 + 报名表单 + 报名成功，适合社团招新', '', '{
  "intent": "社团招新",
  "reason": "模板：招新场景的标准四页结构",
  "theme": {
    "primary": "#4f46e5",
    "accent": "#8b5cf6",
    "bg": "#f7f8fc",
    "text": "#111827",
    "radius": 16,
    "fontScale": 1,
    "spacing": 1,
    "buttonStyle": "gradient",
    "font": "sans"
  },
  "title": "光影摄影社 2026 秋季招新",
  "meta": {
    "org": "光影摄影社",
    "startAt": "11月8日 周六 19:00",
    "place": "三教 402",
    "deadline": "11月6日 22:00",
    "capacity": 60,
    "contact": "QQ 群 123456"
  },
  "pages": [
    {
      "id": "page_a5731de3",
      "name": "首页",
      "role": "home",
      "bg": "",
      "blocks": [
        {
          "id": "blk_c575fc88",
          "type": "nav",
          "props": {
            "title": "光影摄影社",
            "right": "2026 秋",
            "showBack": true
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_2ee19b13",
          "type": "banner",
          "props": {
            "title": "光影摄影社 2026 秋季招新",
            "subtitle": "每周一次外拍，期末出作品集",
            "image": "",
            "height": 220
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_338bb872",
          "type": "infoCard",
          "props": {
            "title": "活动信息",
            "items": [
              {
                "id": "it_a7f005",
                "icon": "time",
                "label": "时间",
                "value": "11月8日 周六 19:00"
              },
              {
                "id": "it_61d533",
                "icon": "place",
                "label": "地点",
                "value": "三教 402"
              },
              {
                "id": "it_1f0097",
                "icon": "org",
                "label": "主办",
                "value": "光影摄影社"
              },
              {
                "id": "it_dfdb7c",
                "icon": "people",
                "label": "名额",
                "value": "限 60 人"
              }
            ]
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_2c615330",
          "type": "text",
          "props": {
            "text": "我们每周三晚上外拍，期末出一次作品集。不需要你有相机，社团有 4 台备用机。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_44051189",
          "type": "button",
          "props": {
            "text": "我要报名",
            "variant": "primary",
            "full": true,
            "action": {
              "type": "page",
              "pageId": "",
              "url": "",
              "targetRole": "form"
            }
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_849d4f57",
      "name": "了解我们",
      "role": "content",
      "bg": "",
      "blocks": [
        {
          "id": "blk_8ec9f8c4",
          "type": "heading",
          "props": {
            "text": "我们做什么",
            "sub": "四个方向同时招",
            "size": "lg"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_99065e1a",
          "type": "text",
          "props": {
            "text": "人像、风光、后期、视频四个方向，选一个你喜欢的。每周一次集体外拍，每月一次评片会。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_2d0a9e7e",
          "type": "image",
          "props": {
            "url": "",
            "caption": "往届外拍现场",
            "ratio": "4:3"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_416dd3c8",
          "type": "heading",
          "props": {
            "text": "面试安排",
            "sub": "",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_2c94fab5",
          "type": "text",
          "props": {
            "text": "11月8日 19:00 三教 402，带着你手机里最喜欢的三张照片来就行。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_fb3a76a4",
          "type": "button",
          "props": {
            "text": "我也要报名",
            "variant": "primary",
            "full": true,
            "action": {
              "type": "page",
              "pageId": "",
              "url": "",
              "targetRole": "form"
            }
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_d738cba3",
      "name": "报名",
      "role": "form",
      "bg": "",
      "blocks": [
        {
          "id": "blk_28f46f7e",
          "type": "nav",
          "props": {
            "title": "填写报名信息",
            "right": "",
            "showBack": true
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_c0642b01",
          "type": "heading",
          "props": {
            "text": "报名信息",
            "sub": "面试通知会发到手机",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_203fa141",
          "type": "form",
          "props": {
            "title": "报名信息",
            "buttonText": "提交报名",
            "successHint": "提交后我们会通知你",
            "fields": [
              {
                "id": "f_47b6b4",
                "label": "姓名",
                "type": "text",
                "required": true,
                "placeholder": "请输入姓名",
                "options": []
              },
              {
                "id": "f_5a1486",
                "label": "手机号",
                "type": "tel",
                "required": true,
                "placeholder": "用于接收面试通知",
                "options": []
              },
              {
                "id": "f_9d88fa",
                "label": "意向部门",
                "type": "select",
                "required": true,
                "placeholder": "选一个方向",
                "options": [
                  "人像",
                  "风光",
                  "后期",
                  "视频"
                ]
              },
              {
                "id": "f_c64ecd",
                "label": "自我介绍",
                "type": "textarea",
                "required": false,
                "placeholder": "有什么想告诉我们的",
                "options": []
              }
            ]
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_d9d6d85f",
          "type": "countdown",
          "props": {
            "target": "2026-11-06 22:00",
            "label": "距离报名截止",
            "doneText": "报名已截止"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_efac73f8",
      "name": "报名成功",
      "role": "success",
      "bg": "",
      "blocks": [
        {
          "id": "blk_4cd968f3",
          "type": "nav",
          "props": {
            "title": "报名成功",
            "right": "",
            "showBack": false
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_7ea8a902",
          "type": "heading",
          "props": {
            "text": "报名成功",
            "sub": "我们 11月8日见",
            "size": "xl"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_27c2d080",
          "type": "text",
          "props": {
            "text": "面试通知会在 11月7日 前发到你留的手机号上，记得看短信。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_13be03e3",
          "type": "qrcode",
          "props": {
            "url": "",
            "label": "扫码进招新群",
            "size": 132
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    }
  ]
}', 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), category = VALUES(category),
                        description = VALUES(description), document = VALUES(document),
                        is_active = 1;

INSERT INTO templates (id, code, name, category, description, cover_url, document, is_active)
VALUES ('00000000-0000-4000-8000-000000000102', 'registration-event', '活动报名', 'registration', '首页 + 活动详情 + 报名表单 + 倒计时，适合讲座/比赛', '', '{
  "intent": "活动报名",
  "reason": "模板：讲座/比赛类报名页",
  "theme": {
    "primary": "#0284c7",
    "accent": "#06b6d4",
    "bg": "#f2f9fe",
    "text": "#0b2536",
    "radius": 16,
    "fontScale": 1,
    "spacing": 1,
    "buttonStyle": "gradient",
    "font": "sans"
  },
  "title": "校园 AI 应用分享会",
  "meta": {
    "org": "计算机学院学生会",
    "startAt": "11月15日 周五 19:00",
    "place": "图书馆报告厅",
    "deadline": "11月14日 22:00",
    "capacity": 120,
    "contact": "13800138000"
  },
  "pages": [
    {
      "id": "page_5aa35242",
      "name": "首页",
      "role": "home",
      "bg": "",
      "blocks": [
        {
          "id": "blk_59b8ef46",
          "type": "nav",
          "props": {
            "title": "AI 分享会",
            "right": "",
            "showBack": true
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_53451c64",
          "type": "banner",
          "props": {
            "title": "校园 AI 应用分享会",
            "subtitle": "三个真实项目，从想法到上线",
            "image": "",
            "height": 220
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_ec88a315",
          "type": "infoCard",
          "props": {
            "title": "活动信息",
            "items": [
              {
                "id": "it_e629fb",
                "icon": "time",
                "label": "时间",
                "value": "11月15日 周五 19:00"
              },
              {
                "id": "it_ae4239",
                "icon": "place",
                "label": "地点",
                "value": "图书馆报告厅"
              },
              {
                "id": "it_14aee8",
                "icon": "org",
                "label": "主办",
                "value": "计算机学院学生会"
              },
              {
                "id": "it_ac09b1",
                "icon": "people",
                "label": "名额",
                "value": "限 120 人"
              }
            ]
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_7cf00130",
          "type": "text",
          "props": {
            "text": "三位学长带来自己在校期间做的 AI 项目，从选题、踩坑到部署，全程不讲空话。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_72bc4526",
          "type": "button",
          "props": {
            "text": "我要占座",
            "variant": "primary",
            "full": true,
            "action": {
              "type": "page",
              "pageId": "",
              "url": "",
              "targetRole": "form"
            }
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_830421c9",
      "name": "活动详情",
      "role": "content",
      "bg": "",
      "blocks": [
        {
          "id": "blk_db5b876f",
          "type": "heading",
          "props": {
            "text": "分享内容",
            "sub": "",
            "size": "lg"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_5da042c8",
          "type": "text",
          "props": {
            "text": "19:00 校园活动页生成器 / 19:40 课程问答机器人 / 20:20 自由交流",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_d57eacd7",
          "type": "divider",
          "props": {
            "label": "注意事项"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_d516f088",
          "type": "text",
          "props": {
            "text": "现场提供 50 个座位，其余站票。结束后有半小时自由提问。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_1825b996",
          "type": "button",
          "props": {
            "text": "返回报名",
            "variant": "primary",
            "full": true,
            "action": {
              "type": "page",
              "pageId": "",
              "url": "",
              "targetRole": "form"
            }
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_6f1e9736",
      "name": "报名",
      "role": "form",
      "bg": "",
      "blocks": [
        {
          "id": "blk_e55cdc6e",
          "type": "nav",
          "props": {
            "title": "报名",
            "right": "",
            "showBack": true
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_3c85a995",
          "type": "heading",
          "props": {
            "text": "报名信息",
            "sub": "",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_7770b2c2",
          "type": "form",
          "props": {
            "title": "报名信息",
            "buttonText": "提交报名",
            "successHint": "提交后我们会通知你",
            "fields": [
              {
                "id": "f_51e1cd",
                "label": "姓名",
                "type": "text",
                "required": true,
                "placeholder": "请输入姓名",
                "options": []
              },
              {
                "id": "f_b69f6c",
                "label": "手机号",
                "type": "tel",
                "required": true,
                "placeholder": "用于发送入场通知",
                "options": []
              },
              {
                "id": "f_ce6fc2",
                "label": "学院班级",
                "type": "text",
                "required": true,
                "placeholder": "例如 计算机 2301",
                "options": []
              }
            ]
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_41b0e016",
          "type": "countdown",
          "props": {
            "target": "2026-11-14 22:00",
            "label": "距离报名截止",
            "doneText": "报名已截止"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_c1529833",
      "name": "报名成功",
      "role": "success",
      "bg": "",
      "blocks": [
        {
          "id": "blk_803b6b92",
          "type": "nav",
          "props": {
            "title": "报名成功",
            "right": "",
            "showBack": false
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_a63a8254",
          "type": "heading",
          "props": {
            "text": "报名成功",
            "sub": "",
            "size": "xl"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_354032bf",
          "type": "text",
          "props": {
            "text": "11月15日 18:40 开始入场，报告厅在东门进去左转。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_824d89d0",
          "type": "qrcode",
          "props": {
            "url": "",
            "label": "扫码查看活动详情",
            "size": 132
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    }
  ]
}', 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), category = VALUES(category),
                        description = VALUES(description), document = VALUES(document),
                        is_active = 1;

INSERT INTO templates (id, code, name, category, description, cover_url, document, is_active)
VALUES ('00000000-0000-4000-8000-000000000103', 'vote-contest', '投票评选', 'vote', '首页 + 规则 + 单选投票 + 结果页，适合人气评选', '', '{
  "intent": "投票评选",
  "reason": "模板：人气投票页",
  "theme": {
    "primary": "#db2777",
    "accent": "#f472b6",
    "bg": "#fdf5f9",
    "text": "#2b0f1f",
    "radius": 16,
    "fontScale": 1,
    "spacing": 1,
    "buttonStyle": "gradient",
    "font": "sans"
  },
  "title": "校园歌手大赛人气投票",
  "meta": {
    "org": "校学生会文艺部",
    "startAt": "11月20日 19:00",
    "place": "大学生活动中心",
    "deadline": "11月18日 22:00",
    "capacity": 0,
    "contact": "学生会公众号"
  },
  "pages": [
    {
      "id": "page_036f04a9",
      "name": "首页",
      "role": "home",
      "bg": "",
      "blocks": [
        {
          "id": "blk_a0403587",
          "type": "nav",
          "props": {
            "title": "人气投票",
            "right": "2026",
            "showBack": true
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_db1c80c4",
          "type": "banner",
          "props": {
            "title": "这一次由你来决定",
            "subtitle": "校园歌手大赛人气奖投票",
            "image": "",
            "height": 220
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_5ae30fc7",
          "type": "text",
          "props": {
            "text": "每人一票，投给你心里的那个声音。投票截止 11月18日 22:00，结果 11月20日 现场公布。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_3d4e2b7e",
          "type": "heading",
          "props": {
            "text": "投票规则",
            "sub": "",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_0b416357",
          "type": "text",
          "props": {
            "text": "一人一票，同一手机号只能投一次。禁止刷票，发现取消资格。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_00f569cf",
          "type": "button",
          "props": {
            "text": "开始投票",
            "variant": "primary",
            "full": true,
            "action": {
              "type": "page",
              "pageId": "",
              "url": "",
              "targetRole": "form"
            }
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_77c50d03",
      "name": "投票",
      "role": "form",
      "bg": "",
      "blocks": [
        {
          "id": "blk_95b1f443",
          "type": "nav",
          "props": {
            "title": "投票",
            "right": "",
            "showBack": true
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_cbaad6c1",
          "type": "heading",
          "props": {
            "text": "选一个",
            "sub": "",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_d2bd0f70",
          "type": "radio",
          "props": {
            "question": "你的一票投给谁",
            "options": [
              "01 号 李同学",
              "02 号 王同学",
              "03 号 张同学"
            ],
            "required": true,
            "hint": "只有一票，慎重"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_e4f65b68",
          "type": "form",
          "props": {
            "title": "确认信息",
            "buttonText": "提交投票",
            "successHint": "提交后我们会通知你",
            "fields": [
              {
                "id": "f_9191b9",
                "label": "你的学院",
                "type": "select",
                "required": true,
                "placeholder": "用于分组统计",
                "options": [
                  "文学院",
                  "理学院",
                  "工学院",
                  "其他"
                ]
              }
            ]
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_6820688b",
      "name": "投票成功",
      "role": "success",
      "bg": "",
      "blocks": [
        {
          "id": "blk_976895c9",
          "type": "nav",
          "props": {
            "title": "投票成功",
            "right": "",
            "showBack": false
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_474c0890",
          "type": "heading",
          "props": {
            "text": "投票成功",
            "sub": "",
            "size": "xl"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_cc38d90d",
          "type": "text",
          "props": {
            "text": "感谢参与。最终结果以主办方公示为准，11月20日 现场公布。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_72bce801",
          "type": "qrcode",
          "props": {
            "url": "",
            "label": "扫码看结果",
            "size": 132
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    }
  ]
}', 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), category = VALUES(category),
                        description = VALUES(description), document = VALUES(document),
                        is_active = 1;

INSERT INTO templates (id, code, name, category, description, cover_url, document, is_active)
VALUES ('00000000-0000-4000-8000-000000000104', 'checkin-daily', '每日打卡', 'checkin', '首页 + 打卡表单 + 成功页，适合 21 天挑战类活动', '', '{
  "intent": "每日打卡",
  "reason": "模板：21 天打卡挑战",
  "theme": {
    "primary": "#059669",
    "accent": "#84cc16",
    "bg": "#f4fbf7",
    "text": "#0d2419",
    "radius": 16,
    "fontScale": 1,
    "spacing": 1,
    "buttonStyle": "gradient",
    "font": "sans"
  },
  "title": "21 天阅读打卡计划",
  "meta": {
    "org": "图书馆学生协会",
    "startAt": "11月1日 起 共 21 天",
    "place": "线上",
    "deadline": "每天 24:00 前",
    "capacity": 0,
    "contact": "阅读协会群"
  },
  "pages": [
    {
      "id": "page_f2cbea01",
      "name": "首页",
      "role": "home",
      "bg": "",
      "blocks": [
        {
          "id": "blk_ed3441c5",
          "type": "nav",
          "props": {
            "title": "21 天阅读",
            "right": "打卡",
            "showBack": true
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_dd1a112f",
          "type": "banner",
          "props": {
            "title": "每天读一点",
            "subtitle": "21 天阅读打卡挑战",
            "image": "",
            "height": 220
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_24c95c5f",
          "type": "infoCard",
          "props": {
            "title": "活动信息",
            "items": [
              {
                "id": "it_714964",
                "icon": "time",
                "label": "周期",
                "value": "11月1日 - 11月21日"
              },
              {
                "id": "it_0541bc",
                "icon": "place",
                "label": "方式",
                "value": "线上提交"
              },
              {
                "id": "it_d83a72",
                "icon": "org",
                "label": "主办",
                "value": "图书馆学生协会"
              },
              {
                "id": "it_1de527",
                "icon": "ticket",
                "label": "奖励",
                "value": "满 18 天送书签"
              }
            ]
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_e0200c64",
          "type": "text",
          "props": {
            "text": "每天 24:00 前提交今天的阅读记录，连续满 18 天算完成。书不限，页数不限。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_77a25c25",
          "type": "button",
          "props": {
            "text": "今天打卡",
            "variant": "primary",
            "full": true,
            "action": {
              "type": "page",
              "pageId": "",
              "url": "",
              "targetRole": "form"
            }
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_c452c153",
      "name": "今日打卡",
      "role": "form",
      "bg": "",
      "blocks": [
        {
          "id": "blk_0062e900",
          "type": "nav",
          "props": {
            "title": "今日打卡",
            "right": "",
            "showBack": true
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_c3a1c1d5",
          "type": "heading",
          "props": {
            "text": "今天的记录",
            "sub": "",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_93464ab3",
          "type": "form",
          "props": {
            "title": "今日打卡",
            "buttonText": "提交打卡",
            "successHint": "提交成功即算今天已打卡",
            "fields": [
              {
                "id": "f_5bd779",
                "label": "姓名",
                "type": "text",
                "required": true,
                "placeholder": "请输入姓名",
                "options": []
              },
              {
                "id": "f_0339c3",
                "label": "学号",
                "type": "text",
                "required": true,
                "placeholder": "用于统计",
                "options": []
              },
              {
                "id": "f_2d5407",
                "label": "今天读了什么",
                "type": "textarea",
                "required": true,
                "placeholder": "书名 + 页数，或一句感想",
                "options": []
              }
            ]
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_9aa611d2",
      "name": "打卡成功",
      "role": "success",
      "bg": "",
      "blocks": [
        {
          "id": "blk_6444e965",
          "type": "nav",
          "props": {
            "title": "打卡成功",
            "right": "",
            "showBack": false
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_ac2e977f",
          "type": "heading",
          "props": {
            "text": "今天已打卡",
            "sub": "明天 24:00 前再来",
            "size": "xl"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_d7fb123d",
          "type": "text",
          "props": {
            "text": "连续记录会显示在活动结束后发的电子证书上，别断。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_3e21f763",
          "type": "qrcode",
          "props": {
            "url": "",
            "label": "扫码进读书群",
            "size": 132
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    }
  ]
}', 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), category = VALUES(category),
                        description = VALUES(description), document = VALUES(document),
                        is_active = 1;

-- ---------------------------------------------------------------- 3) 演示项目草稿

UPDATE projects
   SET draft_document = '{
  "intent": "社团招新",
  "reason": "模板：招新场景的标准四页结构",
  "theme": {
    "primary": "#4f46e5",
    "accent": "#8b5cf6",
    "bg": "#f7f8fc",
    "text": "#111827",
    "radius": 16,
    "fontScale": 1,
    "spacing": 1,
    "buttonStyle": "gradient",
    "font": "sans"
  },
  "title": "摄影社招新（演示）",
  "meta": {
    "org": "光影摄影社",
    "startAt": "11月8日 周六 19:00",
    "place": "三教 402",
    "deadline": "11月6日 22:00",
    "capacity": 60,
    "contact": "QQ 群 123456"
  },
  "pages": [
    {
      "id": "page_a5731de3",
      "name": "首页",
      "role": "home",
      "bg": "",
      "blocks": [
        {
          "id": "blk_c575fc88",
          "type": "nav",
          "props": {
            "title": "光影摄影社",
            "right": "2026 秋",
            "showBack": true
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_2ee19b13",
          "type": "banner",
          "props": {
            "title": "光影摄影社 2026 秋季招新",
            "subtitle": "每周一次外拍，期末出作品集",
            "image": "",
            "height": 220
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_338bb872",
          "type": "infoCard",
          "props": {
            "title": "活动信息",
            "items": [
              {
                "id": "it_a7f005",
                "icon": "time",
                "label": "时间",
                "value": "11月8日 周六 19:00"
              },
              {
                "id": "it_61d533",
                "icon": "place",
                "label": "地点",
                "value": "三教 402"
              },
              {
                "id": "it_1f0097",
                "icon": "org",
                "label": "主办",
                "value": "光影摄影社"
              },
              {
                "id": "it_dfdb7c",
                "icon": "people",
                "label": "名额",
                "value": "限 60 人"
              }
            ]
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_2c615330",
          "type": "text",
          "props": {
            "text": "我们每周三晚上外拍，期末出一次作品集。不需要你有相机，社团有 4 台备用机。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_44051189",
          "type": "button",
          "props": {
            "text": "我要报名",
            "variant": "primary",
            "full": true,
            "action": {
              "type": "page",
              "pageId": "",
              "url": "",
              "targetRole": "form"
            }
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_849d4f57",
      "name": "了解我们",
      "role": "content",
      "bg": "",
      "blocks": [
        {
          "id": "blk_8ec9f8c4",
          "type": "heading",
          "props": {
            "text": "我们做什么",
            "sub": "四个方向同时招",
            "size": "lg"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_99065e1a",
          "type": "text",
          "props": {
            "text": "人像、风光、后期、视频四个方向，选一个你喜欢的。每周一次集体外拍，每月一次评片会。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_2d0a9e7e",
          "type": "image",
          "props": {
            "url": "",
            "caption": "往届外拍现场",
            "ratio": "4:3"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_416dd3c8",
          "type": "heading",
          "props": {
            "text": "面试安排",
            "sub": "",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_2c94fab5",
          "type": "text",
          "props": {
            "text": "11月8日 19:00 三教 402，带着你手机里最喜欢的三张照片来就行。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_fb3a76a4",
          "type": "button",
          "props": {
            "text": "我也要报名",
            "variant": "primary",
            "full": true,
            "action": {
              "type": "page",
              "pageId": "",
              "url": "",
              "targetRole": "form"
            }
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_d738cba3",
      "name": "报名",
      "role": "form",
      "bg": "",
      "blocks": [
        {
          "id": "blk_28f46f7e",
          "type": "nav",
          "props": {
            "title": "填写报名信息",
            "right": "",
            "showBack": true
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_c0642b01",
          "type": "heading",
          "props": {
            "text": "报名信息",
            "sub": "面试通知会发到手机",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_203fa141",
          "type": "form",
          "props": {
            "title": "报名信息",
            "buttonText": "提交报名",
            "successHint": "提交后我们会通知你",
            "fields": [
              {
                "id": "f_47b6b4",
                "label": "姓名",
                "type": "text",
                "required": true,
                "placeholder": "请输入姓名",
                "options": []
              },
              {
                "id": "f_5a1486",
                "label": "手机号",
                "type": "tel",
                "required": true,
                "placeholder": "用于接收面试通知",
                "options": []
              },
              {
                "id": "f_9d88fa",
                "label": "意向部门",
                "type": "select",
                "required": true,
                "placeholder": "选一个方向",
                "options": [
                  "人像",
                  "风光",
                  "后期",
                  "视频"
                ]
              },
              {
                "id": "f_c64ecd",
                "label": "自我介绍",
                "type": "textarea",
                "required": false,
                "placeholder": "有什么想告诉我们的",
                "options": []
              }
            ]
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_d9d6d85f",
          "type": "countdown",
          "props": {
            "target": "2026-11-06 22:00",
            "label": "距离报名截止",
            "doneText": "报名已截止"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    },
    {
      "id": "page_efac73f8",
      "name": "报名成功",
      "role": "success",
      "bg": "",
      "blocks": [
        {
          "id": "blk_4cd968f3",
          "type": "nav",
          "props": {
            "title": "报名成功",
            "right": "",
            "showBack": false
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_7ea8a902",
          "type": "heading",
          "props": {
            "text": "报名成功",
            "sub": "我们 11月8日见",
            "size": "xl"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_27c2d080",
          "type": "text",
          "props": {
            "text": "面试通知会在 11月7日 前发到你留的手机号上，记得看短信。",
            "size": "md"
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        },
        {
          "id": "blk_13be03e3",
          "type": "qrcode",
          "props": {
            "url": "",
            "label": "扫码进招新群",
            "size": 132
          },
          "style": {
            "bg": "",
            "paddingX": 20,
            "paddingY": 10,
            "radius": 0,
            "align": "left"
          },
          "hidden": false
        }
      ]
    }
  ],
  "id": "00000000-0000-4000-8000-000000000201",
  "slug": "photo-club-2026",
  "createdAt": 1761740000000,
  "updatedAt": 1761747890000,
  "published": {
    "url": "http://localhost:5173/p/photo-club-2026",
    "slug": "photo-club-2026",
    "at": 1761747890000
  }
}',
       draft_revision = GREATEST(draft_revision, 1),
       status = 'published'
 WHERE id = '00000000-0000-4000-8000-000000000201';

-- ---------------------------------------------------------------- 4) 自检（执行完手动跑一次）
-- SELECT email, display_name, LENGTH(password_hash) AS hash_len FROM users;
-- SELECT code, name, JSON_VALID(document) AS ok FROM templates;
-- SELECT title, JSON_LENGTH(draft_document, '$.pages') AS pages FROM projects;
