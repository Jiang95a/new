-- ============================================================================
-- 005_demo_data.sql —— 演示数据：让「项目列表 / 提交数据 / 统计 / AI 提案 / 导出」
--                      这些页面点开就有东西看，而不是一片空白。
--
-- 幂等：固定 id + ON DUPLICATE KEY UPDATE，重复执行不会翻倍。
-- 只用于演示与联调，不要带到生产。
--
-- 执行：
--   mysql -u root campus_diy -e "source docs/sql/005_demo_data.sql"
-- ============================================================================

SET NAMES utf8mb4;


-- ---------------------------------------------------------------- 1) 四个演示项目

INSERT INTO projects (id, owner_id, template_id, title, description,
  activity_type, cover_tone, cover_code, cover_title, status,
  draft_document, draft_revision, public_slug, publish_settings)
VALUES ('00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000001', NULL, '摄影社招新（演示）', '社团招新演示项目',
  '社团招新', 'photo', 'PHOTO / 26', '寻找校园里的下一帧光', 'published',
  '{"meta": {"org": "光影摄影社", "startAt": "11月8日 周六 19:00", "place": "三教 402", "deadline": "11月6日 22:00", "capacity": 60, "contact": "QQ 群 123456"}, "pages": [{"bg": "", "id": "page_a5731de3", "name": "首页", "role": "home", "blocks": [{"id": "blk_c575fc88", "type": "nav", "props": {"right": "2026 秋", "title": "光影摄影社", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_2ee19b13", "type": "banner", "props": {"image": "", "title": "光影摄影社 2026 秋季招新", "height": 220, "subtitle": "每周一次外拍，期末出作品集"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_338bb872", "type": "infoCard", "props": {"items": [{"id": "it_a7f005", "icon": "time", "label": "时间", "value": "11月8日 周六 19:00"}, {"id": "it_61d533", "icon": "place", "label": "地点", "value": "三教 402"}, {"id": "it_1f0097", "icon": "org", "label": "主办", "value": "光影摄影社"}, {"id": "it_dfdb7c", "icon": "people", "label": "名额", "value": "限 60 人"}], "title": "活动信息"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_2c615330", "type": "text", "props": {"size": "md", "text": "我们每周三晚上外拍，期末出一次作品集。不需要你有相机，社团有 4 台备用机。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_44051189", "type": "button", "props": {"full": true, "text": "我要报名", "action": {"url": "", "type": "page", "pageId": "", "targetRole": "form"}, "variant": "primary"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_849d4f57", "name": "了解我们", "role": "content", "blocks": [{"id": "blk_8ec9f8c4", "type": "heading", "props": {"sub": "四个方向同时招", "size": "lg", "text": "我们做什么"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_99065e1a", "type": "text", "props": {"size": "md", "text": "人像、风光、后期、视频四个方向，选一个你喜欢的。每周一次集体外拍，每月一次评片会。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_2d0a9e7e", "type": "image", "props": {"url": "", "ratio": "4:3", "caption": "往届外拍现场"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_416dd3c8", "type": "heading", "props": {"sub": "", "size": "md", "text": "面试安排"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_2c94fab5", "type": "text", "props": {"size": "md", "text": "11月8日 19:00 三教 402，带着你手机里最喜欢的三张照片来就行。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_fb3a76a4", "type": "button", "props": {"full": true, "text": "我也要报名", "action": {"url": "", "type": "page", "pageId": "", "targetRole": "form"}, "variant": "primary"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_d738cba3", "name": "报名", "role": "form", "blocks": [{"id": "blk_28f46f7e", "type": "nav", "props": {"right": "", "title": "填写报名信息", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_c0642b01", "type": "heading", "props": {"sub": "面试通知会发到手机", "size": "md", "text": "报名信息"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_203fa141", "type": "form", "props": {"title": "报名信息", "fields": [{"id": "f_47b6b4", "type": "text", "label": "姓名", "options": [], "required": true, "placeholder": "请输入姓名"}, {"id": "f_5a1486", "type": "tel", "label": "手机号", "options": [], "required": true, "placeholder": "用于接收面试通知"}, {"id": "f_9d88fa", "type": "select", "label": "意向部门", "options": ["人像", "风光", "后期", "视频"], "required": true, "placeholder": "选一个方向"}, {"id": "f_c64ecd", "type": "textarea", "label": "自我介绍", "options": [], "required": false, "placeholder": "有什么想告诉我们的"}], "buttonText": "提交报名", "successHint": "提交后我们会通知你"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_d9d6d85f", "type": "countdown", "props": {"label": "距离报名截止", "target": "2026-11-06 22:00", "doneText": "报名已截止"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_efac73f8", "name": "报名成功", "role": "success", "blocks": [{"id": "blk_4cd968f3", "type": "nav", "props": {"right": "", "title": "报名成功", "showBack": false}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_7ea8a902", "type": "heading", "props": {"sub": "我们 11月8日见", "size": "xl", "text": "报名成功"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_27c2d080", "type": "text", "props": {"size": "md", "text": "面试通知会在 11月7日 前发到你留的手机号上，记得看短信。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_13be03e3", "type": "qrcode", "props": {"url": "", "size": 132, "label": "扫码进招新群"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}], "theme": {"bg": "#f7f8fc", "font": "sans", "text": "#111827", "accent": "#8b5cf6", "radius": 16, "primary": "#4f46e5", "spacing": 1, "fontScale": 1, "buttonStyle": "gradient"}, "title": "摄影社招新（演示）", "intent": "社团招新", "reason": "模板：招新场景的标准四页结构", "slug": "photo-club-2026", "id": "00000000-0000-4000-8000-000000000201", "createdAt": 1761740000000, "updatedAt": 1761747890000, "published": {"url": "http://localhost:5173/p/photo-club-2026", "slug": "photo-club-2026", "at": 1761747890000}}', 1, 'photo-club-2026', '{"allowIndex": true}')
ON DUPLICATE KEY UPDATE title = VALUES(title), activity_type = VALUES(activity_type),
  cover_tone = VALUES(cover_tone), cover_code = VALUES(cover_code), cover_title = VALUES(cover_title),
  draft_document = VALUES(draft_document), status = 'published', public_slug = VALUES(public_slug);

INSERT INTO projects (id, owner_id, template_id, title, description,
  activity_type, cover_tone, cover_code, cover_title, status,
  draft_document, draft_revision, public_slug, publish_settings)
VALUES ('00000000-0000-4000-8000-000000000202', '00000000-0000-4000-8000-000000000001', NULL, '校园歌手大赛人气投票', '投票评选演示项目',
  '投票评选', 'music', 'VOICE / LIVE', '这一次
由你来决定', 'published',
  '{"meta": {"org": "校学生会文艺部", "startAt": "11月20日 19:00", "place": "大学生活动中心", "deadline": "11月18日 22:00", "capacity": 0, "contact": "学生会公众号"}, "pages": [{"bg": "", "id": "page_036f04a9", "name": "首页", "role": "home", "blocks": [{"id": "blk_a0403587", "type": "nav", "props": {"right": "2026", "title": "人气投票", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_db1c80c4", "type": "banner", "props": {"image": "", "title": "这一次由你来决定", "height": 220, "subtitle": "校园歌手大赛人气奖投票"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_5ae30fc7", "type": "text", "props": {"size": "md", "text": "每人一票，投给你心里的那个声音。投票截止 11月18日 22:00，结果 11月20日 现场公布。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_3d4e2b7e", "type": "heading", "props": {"sub": "", "size": "md", "text": "投票规则"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_0b416357", "type": "text", "props": {"size": "md", "text": "一人一票，同一手机号只能投一次。禁止刷票，发现取消资格。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_00f569cf", "type": "button", "props": {"full": true, "text": "开始投票", "action": {"url": "", "type": "page", "pageId": "", "targetRole": "form"}, "variant": "primary"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_77c50d03", "name": "投票", "role": "form", "blocks": [{"id": "blk_95b1f443", "type": "nav", "props": {"right": "", "title": "投票", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_cbaad6c1", "type": "heading", "props": {"sub": "", "size": "md", "text": "选一个"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_d2bd0f70", "type": "radio", "props": {"hint": "只有一票，慎重", "options": ["01 号 李同学", "02 号 王同学", "03 号 张同学"], "question": "你的一票投给谁", "required": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_e4f65b68", "type": "form", "props": {"title": "确认信息", "fields": [{"id": "f_9191b9", "type": "select", "label": "你的学院", "options": ["文学院", "理学院", "工学院", "其他"], "required": true, "placeholder": "用于分组统计"}], "buttonText": "提交投票", "successHint": "提交后我们会通知你"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_6820688b", "name": "投票成功", "role": "success", "blocks": [{"id": "blk_976895c9", "type": "nav", "props": {"right": "", "title": "投票成功", "showBack": false}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_474c0890", "type": "heading", "props": {"sub": "", "size": "xl", "text": "投票成功"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_cc38d90d", "type": "text", "props": {"size": "md", "text": "感谢参与。最终结果以主办方公示为准，11月20日 现场公布。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_72bce801", "type": "qrcode", "props": {"url": "", "size": 132, "label": "扫码看结果"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}], "theme": {"bg": "#fdf5f9", "font": "sans", "text": "#2b0f1f", "accent": "#f472b6", "radius": 16, "primary": "#db2777", "spacing": 1, "fontScale": 1, "buttonStyle": "gradient"}, "title": "校园歌手大赛人气投票", "intent": "投票评选", "reason": "模板：人气投票页", "slug": "voice-vote", "id": "00000000-0000-4000-8000-000000000202", "createdAt": 1761740000000, "updatedAt": 1761747890000, "published": {"url": "http://localhost:5173/p/voice-vote", "slug": "voice-vote", "at": 1761747890000}}', 1, 'voice-vote', '{"allowIndex": true}')
ON DUPLICATE KEY UPDATE title = VALUES(title), activity_type = VALUES(activity_type),
  cover_tone = VALUES(cover_tone), cover_code = VALUES(cover_code), cover_title = VALUES(cover_title),
  draft_document = VALUES(draft_document), status = 'published', public_slug = VALUES(public_slug);

INSERT INTO projects (id, owner_id, template_id, title, description,
  activity_type, cover_tone, cover_code, cover_title, status,
  draft_document, draft_revision, public_slug, publish_settings)
VALUES ('00000000-0000-4000-8000-000000000203', '00000000-0000-4000-8000-000000000001', NULL, '21 天阅读打卡计划', '每日打卡演示项目',
  '每日打卡', 'read', 'READ / 21', '每天读一点
把世界读厚', 'published',
  '{"meta": {"org": "图书馆学生协会", "startAt": "11月1日 起 共 21 天", "place": "线上", "deadline": "每天 24:00 前", "capacity": 0, "contact": "阅读协会群"}, "pages": [{"bg": "", "id": "page_f2cbea01", "name": "首页", "role": "home", "blocks": [{"id": "blk_ed3441c5", "type": "nav", "props": {"right": "打卡", "title": "21 天阅读", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_dd1a112f", "type": "banner", "props": {"image": "", "title": "每天读一点", "height": 220, "subtitle": "21 天阅读打卡挑战"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_24c95c5f", "type": "infoCard", "props": {"items": [{"id": "it_714964", "icon": "time", "label": "周期", "value": "11月1日 - 11月21日"}, {"id": "it_0541bc", "icon": "place", "label": "方式", "value": "线上提交"}, {"id": "it_d83a72", "icon": "org", "label": "主办", "value": "图书馆学生协会"}, {"id": "it_1de527", "icon": "ticket", "label": "奖励", "value": "满 18 天送书签"}], "title": "活动信息"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_e0200c64", "type": "text", "props": {"size": "md", "text": "每天 24:00 前提交今天的阅读记录，连续满 18 天算完成。书不限，页数不限。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_77a25c25", "type": "button", "props": {"full": true, "text": "今天打卡", "action": {"url": "", "type": "page", "pageId": "", "targetRole": "form"}, "variant": "primary"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_c452c153", "name": "今日打卡", "role": "form", "blocks": [{"id": "blk_0062e900", "type": "nav", "props": {"right": "", "title": "今日打卡", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_c3a1c1d5", "type": "heading", "props": {"sub": "", "size": "md", "text": "今天的记录"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_93464ab3", "type": "form", "props": {"title": "今日打卡", "fields": [{"id": "f_5bd779", "type": "text", "label": "姓名", "options": [], "required": true, "placeholder": "请输入姓名"}, {"id": "f_0339c3", "type": "text", "label": "学号", "options": [], "required": true, "placeholder": "用于统计"}, {"id": "f_2d5407", "type": "textarea", "label": "今天读了什么", "options": [], "required": true, "placeholder": "书名 + 页数，或一句感想"}], "buttonText": "提交打卡", "successHint": "提交成功即算今天已打卡"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_9aa611d2", "name": "打卡成功", "role": "success", "blocks": [{"id": "blk_6444e965", "type": "nav", "props": {"right": "", "title": "打卡成功", "showBack": false}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_ac2e977f", "type": "heading", "props": {"sub": "明天 24:00 前再来", "size": "xl", "text": "今天已打卡"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_d7fb123d", "type": "text", "props": {"size": "md", "text": "连续记录会显示在活动结束后发的电子证书上，别断。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_3e21f763", "type": "qrcode", "props": {"url": "", "size": 132, "label": "扫码进读书群"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}], "theme": {"bg": "#f4fbf7", "font": "sans", "text": "#0d2419", "accent": "#84cc16", "radius": 16, "primary": "#059669", "spacing": 1, "fontScale": 1, "buttonStyle": "gradient"}, "title": "21 天阅读打卡计划", "intent": "每日打卡", "reason": "模板：21 天打卡挑战", "slug": "reading-plan", "id": "00000000-0000-4000-8000-000000000203", "createdAt": 1761740000000, "updatedAt": 1761747890000, "published": {"url": "http://localhost:5173/p/reading-plan", "slug": "reading-plan", "at": 1761747890000}}', 1, 'reading-plan', '{"allowIndex": true}')
ON DUPLICATE KEY UPDATE title = VALUES(title), activity_type = VALUES(activity_type),
  cover_tone = VALUES(cover_tone), cover_code = VALUES(cover_code), cover_title = VALUES(cover_title),
  draft_document = VALUES(draft_document), status = 'published', public_slug = VALUES(public_slug);

INSERT INTO projects (id, owner_id, template_id, title, description,
  activity_type, cover_tone, cover_code, cover_title, status,
  draft_document, draft_revision, public_slug, publish_settings)
VALUES ('00000000-0000-4000-8000-000000000204', '00000000-0000-4000-8000-000000000001', NULL, '迎新志愿者信息收集', '信息收集演示项目',
  '信息收集', 'volunteer', 'VOLUNTEER', '一起迎接
新的同学', 'published',
  '{"meta": {"org": "青年志愿者协会", "startAt": "9月1日 08:00", "place": "学校东门", "deadline": "8月28日 22:00", "capacity": 80, "contact": "青协办公室"}, "pages": [{"bg": "", "id": "page_5aa35242", "name": "首页", "role": "home", "blocks": [{"id": "blk_59b8ef46", "type": "nav", "props": {"right": "", "title": "AI 分享会", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_53451c64", "type": "banner", "props": {"image": "", "title": "校园 AI 应用分享会", "height": 220, "subtitle": "三个真实项目，从想法到上线"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_ec88a315", "type": "infoCard", "props": {"items": [{"id": "it_e629fb", "icon": "time", "label": "时间", "value": "11月15日 周五 19:00"}, {"id": "it_ae4239", "icon": "place", "label": "地点", "value": "图书馆报告厅"}, {"id": "it_14aee8", "icon": "org", "label": "主办", "value": "计算机学院学生会"}, {"id": "it_ac09b1", "icon": "people", "label": "名额", "value": "限 120 人"}], "title": "活动信息"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_7cf00130", "type": "text", "props": {"size": "md", "text": "三位学长带来自己在校期间做的 AI 项目，从选题、踩坑到部署，全程不讲空话。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_72bc4526", "type": "button", "props": {"full": true, "text": "我要占座", "action": {"url": "", "type": "page", "pageId": "", "targetRole": "form"}, "variant": "primary"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_830421c9", "name": "活动详情", "role": "content", "blocks": [{"id": "blk_db5b876f", "type": "heading", "props": {"sub": "", "size": "lg", "text": "分享内容"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_5da042c8", "type": "text", "props": {"size": "md", "text": "19:00 校园活动页生成器 / 19:40 课程问答机器人 / 20:20 自由交流"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_d57eacd7", "type": "divider", "props": {"label": "注意事项"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_d516f088", "type": "text", "props": {"size": "md", "text": "现场提供 50 个座位，其余站票。结束后有半小时自由提问。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_1825b996", "type": "button", "props": {"full": true, "text": "返回报名", "action": {"url": "", "type": "page", "pageId": "", "targetRole": "form"}, "variant": "primary"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_6f1e9736", "name": "报名", "role": "form", "blocks": [{"id": "blk_e55cdc6e", "type": "nav", "props": {"right": "", "title": "报名", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_3c85a995", "type": "heading", "props": {"sub": "", "size": "md", "text": "报名信息"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_7770b2c2", "type": "form", "props": {"title": "报名信息", "fields": [{"id": "f_51e1cd", "type": "text", "label": "姓名", "options": [], "required": true, "placeholder": "请输入姓名"}, {"id": "f_b69f6c", "type": "tel", "label": "手机号", "options": [], "required": true, "placeholder": "用于发送入场通知"}, {"id": "f_ce6fc2", "type": "text", "label": "学院班级", "options": [], "required": true, "placeholder": "例如 计算机 2301"}], "buttonText": "提交报名", "successHint": "提交后我们会通知你"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_41b0e016", "type": "countdown", "props": {"label": "距离报名截止", "target": "2026-11-14 22:00", "doneText": "报名已截止"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_c1529833", "name": "报名成功", "role": "success", "blocks": [{"id": "blk_803b6b92", "type": "nav", "props": {"right": "", "title": "报名成功", "showBack": false}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_a63a8254", "type": "heading", "props": {"sub": "", "size": "xl", "text": "报名成功"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_354032bf", "type": "text", "props": {"size": "md", "text": "11月15日 18:40 开始入场，报告厅在东门进去左转。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_824d89d0", "type": "qrcode", "props": {"url": "", "size": 132, "label": "扫码查看活动详情"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}], "theme": {"bg": "#f2f9fe", "font": "sans", "text": "#0b2536", "accent": "#06b6d4", "radius": 16, "primary": "#0284c7", "spacing": 1, "fontScale": 1, "buttonStyle": "gradient"}, "title": "迎新志愿者信息收集", "intent": "活动报名", "reason": "模板：讲座/比赛类报名页", "slug": "volunteer-2026", "id": "00000000-0000-4000-8000-000000000204", "createdAt": 1761740000000, "updatedAt": 1761747890000, "published": {"url": "http://localhost:5173/p/volunteer-2026", "slug": "volunteer-2026", "at": 1761747890000}}', 1, 'volunteer-2026', '{"allowIndex": true}')
ON DUPLICATE KEY UPDATE title = VALUES(title), activity_type = VALUES(activity_type),
  cover_tone = VALUES(cover_tone), cover_code = VALUES(cover_code), cover_title = VALUES(cover_title),
  draft_document = VALUES(draft_document), status = 'published', public_slug = VALUES(public_slug);

-- ---------------------------------------------------------------- 2) 每个项目一条发布版本

INSERT INTO page_versions (id, project_id, version_no, document, source, created_by)
VALUES ('00000000-0000-4000-8000-000000000301', '00000000-0000-4000-8000-000000000201', 1, '{"meta": {"org": "光影摄影社", "startAt": "11月8日 周六 19:00", "place": "三教 402", "deadline": "11月6日 22:00", "capacity": 60, "contact": "QQ 群 123456"}, "pages": [{"bg": "", "id": "page_a5731de3", "name": "首页", "role": "home", "blocks": [{"id": "blk_c575fc88", "type": "nav", "props": {"right": "2026 秋", "title": "光影摄影社", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_2ee19b13", "type": "banner", "props": {"image": "", "title": "光影摄影社 2026 秋季招新", "height": 220, "subtitle": "每周一次外拍，期末出作品集"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_338bb872", "type": "infoCard", "props": {"items": [{"id": "it_a7f005", "icon": "time", "label": "时间", "value": "11月8日 周六 19:00"}, {"id": "it_61d533", "icon": "place", "label": "地点", "value": "三教 402"}, {"id": "it_1f0097", "icon": "org", "label": "主办", "value": "光影摄影社"}, {"id": "it_dfdb7c", "icon": "people", "label": "名额", "value": "限 60 人"}], "title": "活动信息"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_2c615330", "type": "text", "props": {"size": "md", "text": "我们每周三晚上外拍，期末出一次作品集。不需要你有相机，社团有 4 台备用机。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_44051189", "type": "button", "props": {"full": true, "text": "我要报名", "action": {"url": "", "type": "page", "pageId": "", "targetRole": "form"}, "variant": "primary"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_849d4f57", "name": "了解我们", "role": "content", "blocks": [{"id": "blk_8ec9f8c4", "type": "heading", "props": {"sub": "四个方向同时招", "size": "lg", "text": "我们做什么"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_99065e1a", "type": "text", "props": {"size": "md", "text": "人像、风光、后期、视频四个方向，选一个你喜欢的。每周一次集体外拍，每月一次评片会。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_2d0a9e7e", "type": "image", "props": {"url": "", "ratio": "4:3", "caption": "往届外拍现场"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_416dd3c8", "type": "heading", "props": {"sub": "", "size": "md", "text": "面试安排"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_2c94fab5", "type": "text", "props": {"size": "md", "text": "11月8日 19:00 三教 402，带着你手机里最喜欢的三张照片来就行。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_fb3a76a4", "type": "button", "props": {"full": true, "text": "我也要报名", "action": {"url": "", "type": "page", "pageId": "", "targetRole": "form"}, "variant": "primary"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_d738cba3", "name": "报名", "role": "form", "blocks": [{"id": "blk_28f46f7e", "type": "nav", "props": {"right": "", "title": "填写报名信息", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_c0642b01", "type": "heading", "props": {"sub": "面试通知会发到手机", "size": "md", "text": "报名信息"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_203fa141", "type": "form", "props": {"title": "报名信息", "fields": [{"id": "f_47b6b4", "type": "text", "label": "姓名", "options": [], "required": true, "placeholder": "请输入姓名"}, {"id": "f_5a1486", "type": "tel", "label": "手机号", "options": [], "required": true, "placeholder": "用于接收面试通知"}, {"id": "f_9d88fa", "type": "select", "label": "意向部门", "options": ["人像", "风光", "后期", "视频"], "required": true, "placeholder": "选一个方向"}, {"id": "f_c64ecd", "type": "textarea", "label": "自我介绍", "options": [], "required": false, "placeholder": "有什么想告诉我们的"}], "buttonText": "提交报名", "successHint": "提交后我们会通知你"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_d9d6d85f", "type": "countdown", "props": {"label": "距离报名截止", "target": "2026-11-06 22:00", "doneText": "报名已截止"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_efac73f8", "name": "报名成功", "role": "success", "blocks": [{"id": "blk_4cd968f3", "type": "nav", "props": {"right": "", "title": "报名成功", "showBack": false}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_7ea8a902", "type": "heading", "props": {"sub": "我们 11月8日见", "size": "xl", "text": "报名成功"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_27c2d080", "type": "text", "props": {"size": "md", "text": "面试通知会在 11月7日 前发到你留的手机号上，记得看短信。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_13be03e3", "type": "qrcode", "props": {"url": "", "size": 132, "label": "扫码进招新群"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}], "theme": {"bg": "#f7f8fc", "font": "sans", "text": "#111827", "accent": "#8b5cf6", "radius": 16, "primary": "#4f46e5", "spacing": 1, "fontScale": 1, "buttonStyle": "gradient"}, "title": "摄影社招新（演示）", "intent": "社团招新", "reason": "模板：招新场景的标准四页结构", "slug": "photo-club-2026", "id": "00000000-0000-4000-8000-000000000201", "createdAt": 1761740000000, "updatedAt": 1761747890000, "published": {"url": "http://localhost:5173/p/photo-club-2026", "slug": "photo-club-2026", "at": 1761747890000}}', 'template', '00000000-0000-4000-8000-000000000001')
ON DUPLICATE KEY UPDATE document = VALUES(document);

UPDATE projects SET published_version_id = '00000000-0000-4000-8000-000000000301' WHERE id = '00000000-0000-4000-8000-000000000201';

INSERT INTO page_versions (id, project_id, version_no, document, source, created_by)
VALUES ('00000000-0000-4000-8000-000000000302', '00000000-0000-4000-8000-000000000202', 1, '{"meta": {"org": "校学生会文艺部", "startAt": "11月20日 19:00", "place": "大学生活动中心", "deadline": "11月18日 22:00", "capacity": 0, "contact": "学生会公众号"}, "pages": [{"bg": "", "id": "page_036f04a9", "name": "首页", "role": "home", "blocks": [{"id": "blk_a0403587", "type": "nav", "props": {"right": "2026", "title": "人气投票", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_db1c80c4", "type": "banner", "props": {"image": "", "title": "这一次由你来决定", "height": 220, "subtitle": "校园歌手大赛人气奖投票"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_5ae30fc7", "type": "text", "props": {"size": "md", "text": "每人一票，投给你心里的那个声音。投票截止 11月18日 22:00，结果 11月20日 现场公布。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_3d4e2b7e", "type": "heading", "props": {"sub": "", "size": "md", "text": "投票规则"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_0b416357", "type": "text", "props": {"size": "md", "text": "一人一票，同一手机号只能投一次。禁止刷票，发现取消资格。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_00f569cf", "type": "button", "props": {"full": true, "text": "开始投票", "action": {"url": "", "type": "page", "pageId": "", "targetRole": "form"}, "variant": "primary"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_77c50d03", "name": "投票", "role": "form", "blocks": [{"id": "blk_95b1f443", "type": "nav", "props": {"right": "", "title": "投票", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_cbaad6c1", "type": "heading", "props": {"sub": "", "size": "md", "text": "选一个"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_d2bd0f70", "type": "radio", "props": {"hint": "只有一票，慎重", "options": ["01 号 李同学", "02 号 王同学", "03 号 张同学"], "question": "你的一票投给谁", "required": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_e4f65b68", "type": "form", "props": {"title": "确认信息", "fields": [{"id": "f_9191b9", "type": "select", "label": "你的学院", "options": ["文学院", "理学院", "工学院", "其他"], "required": true, "placeholder": "用于分组统计"}], "buttonText": "提交投票", "successHint": "提交后我们会通知你"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_6820688b", "name": "投票成功", "role": "success", "blocks": [{"id": "blk_976895c9", "type": "nav", "props": {"right": "", "title": "投票成功", "showBack": false}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_474c0890", "type": "heading", "props": {"sub": "", "size": "xl", "text": "投票成功"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_cc38d90d", "type": "text", "props": {"size": "md", "text": "感谢参与。最终结果以主办方公示为准，11月20日 现场公布。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_72bce801", "type": "qrcode", "props": {"url": "", "size": 132, "label": "扫码看结果"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}], "theme": {"bg": "#fdf5f9", "font": "sans", "text": "#2b0f1f", "accent": "#f472b6", "radius": 16, "primary": "#db2777", "spacing": 1, "fontScale": 1, "buttonStyle": "gradient"}, "title": "校园歌手大赛人气投票", "intent": "投票评选", "reason": "模板：人气投票页", "slug": "voice-vote", "id": "00000000-0000-4000-8000-000000000202", "createdAt": 1761740000000, "updatedAt": 1761747890000, "published": {"url": "http://localhost:5173/p/voice-vote", "slug": "voice-vote", "at": 1761747890000}}', 'template', '00000000-0000-4000-8000-000000000001')
ON DUPLICATE KEY UPDATE document = VALUES(document);

UPDATE projects SET published_version_id = '00000000-0000-4000-8000-000000000302' WHERE id = '00000000-0000-4000-8000-000000000202';

INSERT INTO page_versions (id, project_id, version_no, document, source, created_by)
VALUES ('00000000-0000-4000-8000-000000000303', '00000000-0000-4000-8000-000000000203', 1, '{"meta": {"org": "图书馆学生协会", "startAt": "11月1日 起 共 21 天", "place": "线上", "deadline": "每天 24:00 前", "capacity": 0, "contact": "阅读协会群"}, "pages": [{"bg": "", "id": "page_f2cbea01", "name": "首页", "role": "home", "blocks": [{"id": "blk_ed3441c5", "type": "nav", "props": {"right": "打卡", "title": "21 天阅读", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_dd1a112f", "type": "banner", "props": {"image": "", "title": "每天读一点", "height": 220, "subtitle": "21 天阅读打卡挑战"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_24c95c5f", "type": "infoCard", "props": {"items": [{"id": "it_714964", "icon": "time", "label": "周期", "value": "11月1日 - 11月21日"}, {"id": "it_0541bc", "icon": "place", "label": "方式", "value": "线上提交"}, {"id": "it_d83a72", "icon": "org", "label": "主办", "value": "图书馆学生协会"}, {"id": "it_1de527", "icon": "ticket", "label": "奖励", "value": "满 18 天送书签"}], "title": "活动信息"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_e0200c64", "type": "text", "props": {"size": "md", "text": "每天 24:00 前提交今天的阅读记录，连续满 18 天算完成。书不限，页数不限。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_77a25c25", "type": "button", "props": {"full": true, "text": "今天打卡", "action": {"url": "", "type": "page", "pageId": "", "targetRole": "form"}, "variant": "primary"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_c452c153", "name": "今日打卡", "role": "form", "blocks": [{"id": "blk_0062e900", "type": "nav", "props": {"right": "", "title": "今日打卡", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_c3a1c1d5", "type": "heading", "props": {"sub": "", "size": "md", "text": "今天的记录"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_93464ab3", "type": "form", "props": {"title": "今日打卡", "fields": [{"id": "f_5bd779", "type": "text", "label": "姓名", "options": [], "required": true, "placeholder": "请输入姓名"}, {"id": "f_0339c3", "type": "text", "label": "学号", "options": [], "required": true, "placeholder": "用于统计"}, {"id": "f_2d5407", "type": "textarea", "label": "今天读了什么", "options": [], "required": true, "placeholder": "书名 + 页数，或一句感想"}], "buttonText": "提交打卡", "successHint": "提交成功即算今天已打卡"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_9aa611d2", "name": "打卡成功", "role": "success", "blocks": [{"id": "blk_6444e965", "type": "nav", "props": {"right": "", "title": "打卡成功", "showBack": false}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_ac2e977f", "type": "heading", "props": {"sub": "明天 24:00 前再来", "size": "xl", "text": "今天已打卡"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_d7fb123d", "type": "text", "props": {"size": "md", "text": "连续记录会显示在活动结束后发的电子证书上，别断。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_3e21f763", "type": "qrcode", "props": {"url": "", "size": 132, "label": "扫码进读书群"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}], "theme": {"bg": "#f4fbf7", "font": "sans", "text": "#0d2419", "accent": "#84cc16", "radius": 16, "primary": "#059669", "spacing": 1, "fontScale": 1, "buttonStyle": "gradient"}, "title": "21 天阅读打卡计划", "intent": "每日打卡", "reason": "模板：21 天打卡挑战", "slug": "reading-plan", "id": "00000000-0000-4000-8000-000000000203", "createdAt": 1761740000000, "updatedAt": 1761747890000, "published": {"url": "http://localhost:5173/p/reading-plan", "slug": "reading-plan", "at": 1761747890000}}', 'template', '00000000-0000-4000-8000-000000000001')
ON DUPLICATE KEY UPDATE document = VALUES(document);

UPDATE projects SET published_version_id = '00000000-0000-4000-8000-000000000303' WHERE id = '00000000-0000-4000-8000-000000000203';

INSERT INTO page_versions (id, project_id, version_no, document, source, created_by)
VALUES ('00000000-0000-4000-8000-000000000304', '00000000-0000-4000-8000-000000000204', 1, '{"meta": {"org": "青年志愿者协会", "startAt": "9月1日 08:00", "place": "学校东门", "deadline": "8月28日 22:00", "capacity": 80, "contact": "青协办公室"}, "pages": [{"bg": "", "id": "page_5aa35242", "name": "首页", "role": "home", "blocks": [{"id": "blk_59b8ef46", "type": "nav", "props": {"right": "", "title": "AI 分享会", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_53451c64", "type": "banner", "props": {"image": "", "title": "校园 AI 应用分享会", "height": 220, "subtitle": "三个真实项目，从想法到上线"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_ec88a315", "type": "infoCard", "props": {"items": [{"id": "it_e629fb", "icon": "time", "label": "时间", "value": "11月15日 周五 19:00"}, {"id": "it_ae4239", "icon": "place", "label": "地点", "value": "图书馆报告厅"}, {"id": "it_14aee8", "icon": "org", "label": "主办", "value": "计算机学院学生会"}, {"id": "it_ac09b1", "icon": "people", "label": "名额", "value": "限 120 人"}], "title": "活动信息"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_7cf00130", "type": "text", "props": {"size": "md", "text": "三位学长带来自己在校期间做的 AI 项目，从选题、踩坑到部署，全程不讲空话。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_72bc4526", "type": "button", "props": {"full": true, "text": "我要占座", "action": {"url": "", "type": "page", "pageId": "", "targetRole": "form"}, "variant": "primary"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_830421c9", "name": "活动详情", "role": "content", "blocks": [{"id": "blk_db5b876f", "type": "heading", "props": {"sub": "", "size": "lg", "text": "分享内容"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_5da042c8", "type": "text", "props": {"size": "md", "text": "19:00 校园活动页生成器 / 19:40 课程问答机器人 / 20:20 自由交流"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_d57eacd7", "type": "divider", "props": {"label": "注意事项"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_d516f088", "type": "text", "props": {"size": "md", "text": "现场提供 50 个座位，其余站票。结束后有半小时自由提问。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_1825b996", "type": "button", "props": {"full": true, "text": "返回报名", "action": {"url": "", "type": "page", "pageId": "", "targetRole": "form"}, "variant": "primary"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_6f1e9736", "name": "报名", "role": "form", "blocks": [{"id": "blk_e55cdc6e", "type": "nav", "props": {"right": "", "title": "报名", "showBack": true}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_3c85a995", "type": "heading", "props": {"sub": "", "size": "md", "text": "报名信息"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_7770b2c2", "type": "form", "props": {"title": "报名信息", "fields": [{"id": "f_51e1cd", "type": "text", "label": "姓名", "options": [], "required": true, "placeholder": "请输入姓名"}, {"id": "f_b69f6c", "type": "tel", "label": "手机号", "options": [], "required": true, "placeholder": "用于发送入场通知"}, {"id": "f_ce6fc2", "type": "text", "label": "学院班级", "options": [], "required": true, "placeholder": "例如 计算机 2301"}], "buttonText": "提交报名", "successHint": "提交后我们会通知你"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_41b0e016", "type": "countdown", "props": {"label": "距离报名截止", "target": "2026-11-14 22:00", "doneText": "报名已截止"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}, {"bg": "", "id": "page_c1529833", "name": "报名成功", "role": "success", "blocks": [{"id": "blk_803b6b92", "type": "nav", "props": {"right": "", "title": "报名成功", "showBack": false}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_a63a8254", "type": "heading", "props": {"sub": "", "size": "xl", "text": "报名成功"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_354032bf", "type": "text", "props": {"size": "md", "text": "11月15日 18:40 开始入场，报告厅在东门进去左转。"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}, {"id": "blk_824d89d0", "type": "qrcode", "props": {"url": "", "size": 132, "label": "扫码查看活动详情"}, "style": {"bg": "", "align": "left", "radius": 0, "paddingX": 20, "paddingY": 10}, "hidden": false}]}], "theme": {"bg": "#f2f9fe", "font": "sans", "text": "#0b2536", "accent": "#06b6d4", "radius": 16, "primary": "#0284c7", "spacing": 1, "fontScale": 1, "buttonStyle": "gradient"}, "title": "迎新志愿者信息收集", "intent": "活动报名", "reason": "模板：讲座/比赛类报名页", "slug": "volunteer-2026", "id": "00000000-0000-4000-8000-000000000204", "createdAt": 1761740000000, "updatedAt": 1761747890000, "published": {"url": "http://localhost:5173/p/volunteer-2026", "slug": "volunteer-2026", "at": 1761747890000}}', 'template', '00000000-0000-4000-8000-000000000001')
ON DUPLICATE KEY UPDATE document = VALUES(document);

UPDATE projects SET published_version_id = '00000000-0000-4000-8000-000000000304' WHERE id = '00000000-0000-4000-8000-000000000204';


-- ---------------------------------------------------------------- 3) 报名提交

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003001', '00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000301', 'page_form', 'blk_form',
  '{"姓名": "王雨桐", "手机号": "13810000001", "意向部门": "人像", "自我介绍": "想学后期"}', '00000000-0000-4000-8000-000000005001', '8ef8d91ba6968027d572bffe1ec126b48767503ad24246176cd4359fd91a4ebe', 'valid', DATE_SUB(NOW(), INTERVAL 1 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003002', '00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000301', 'page_form', 'blk_form',
  '{"姓名": "张一鸣", "手机号": "13810000002", "意向部门": "风光", "自我介绍": "想学后期"}', '00000000-0000-4000-8000-000000005002', 'b29371662c17629e694994150e2aa9bae1fb13a3a625dec299777f510a15eabf', 'valid', DATE_SUB(NOW(), INTERVAL 8 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003003', '00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000301', 'page_form', 'blk_form',
  '{"姓名": "陈可欣", "手机号": "13810000003", "意向部门": "后期", "自我介绍": "想学后期"}', '00000000-0000-4000-8000-000000005003', 'cdffffe8078659b8b28925a7fad78fae3a3163793cc3470e5815ec7588cbff34', 'valid', DATE_SUB(NOW(), INTERVAL 15 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003004', '00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000301', 'page_form', 'blk_form',
  '{"姓名": "刘子豪", "手机号": "13810000004", "意向部门": "视频", "自我介绍": "想学后期"}', '00000000-0000-4000-8000-000000005004', '1d19f373d6c0d1e7ca93d84dfab5e2d726edec08ab841c9d1a3af68df44bfb66', 'valid', DATE_SUB(NOW(), INTERVAL 22 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003005', '00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000301', 'page_form', 'blk_form',
  '{"姓名": "赵梓涵", "手机号": "13810000005", "意向部门": "人像", "自我介绍": "想学后期"}', '00000000-0000-4000-8000-000000005005', '884fb473b4c06398bad88908c2708bf3ef27161cab55fc4431f6bd1976e11011', 'valid', DATE_SUB(NOW(), INTERVAL 29 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003006', '00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000301', 'page_form', 'blk_form',
  '{"姓名": "周予安", "手机号": "13810000006", "意向部门": "风光", "自我介绍": "想学后期"}', '00000000-0000-4000-8000-000000005006', 'd5c0cf42888005fd066a5b768ec60a90e82775f8b00e8371fb86edcace3f2e86', 'valid', DATE_SUB(NOW(), INTERVAL 36 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003007', '00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000301', 'page_form', 'blk_form',
  '{"姓名": "吴清和", "手机号": "13810000007", "意向部门": "后期", "自我介绍": "想学后期"}', '00000000-0000-4000-8000-000000005007', '3d6d16b4464e9021f25a985ade15aefd52eb09d0eff220f2a3a6a3111b806002', 'valid', DATE_SUB(NOW(), INTERVAL 43 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003008', '00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000301', 'page_form', 'blk_form',
  '{"姓名": "郑亦航", "手机号": "13810000008", "意向部门": "视频", "自我介绍": "想学后期"}', '00000000-0000-4000-8000-000000005008', '10d1aed822bc804337b2d861a1b5eb38049030a89270323603d3947939443895', 'valid', DATE_SUB(NOW(), INTERVAL 50 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003009', '00000000-0000-4000-8000-000000000203', '00000000-0000-4000-8000-000000000303', 'page_form', 'blk_form',
  '{"姓名": "孙听雨", "手机号": "13810000009", "学院班级": "计算机 2301"}', '00000000-0000-4000-8000-000000005009', '382fc7aa4164e538d1e03ea0906ff5116a06216f0de44b4b0db8a2c7baaa46eb', 'valid', DATE_SUB(NOW(), INTERVAL 3 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003010', '00000000-0000-4000-8000-000000000203', '00000000-0000-4000-8000-000000000303', 'page_form', 'blk_form',
  '{"姓名": "钱泊舟", "手机号": "13810000010", "学院班级": "计算机 2302"}', '00000000-0000-4000-8000-000000005010', 'a30146b78f2a869143cbe5f6431a887503e34662b58631faea9131f1ff02341b', 'valid', DATE_SUB(NOW(), INTERVAL 10 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003011', '00000000-0000-4000-8000-000000000203', '00000000-0000-4000-8000-000000000303', 'page_form', 'blk_form',
  '{"姓名": "冯知微", "手机号": "13810000011", "学院班级": "计算机 2303"}', '00000000-0000-4000-8000-000000005011', '55fd2ec736dc040d8e0bc9a4e11f9ec042d58e132b0c1a5b4cca5ca2e201fbdf', 'valid', DATE_SUB(NOW(), INTERVAL 17 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003012', '00000000-0000-4000-8000-000000000203', '00000000-0000-4000-8000-000000000303', 'page_form', 'blk_form',
  '{"姓名": "蒋叙白", "手机号": "13810000012", "学院班级": "计算机 2304"}', '00000000-0000-4000-8000-000000005012', '0d20470b3c7082396d5a9884b0a4304e706ce8c64e9943c48307e3af415cdf71', 'valid', DATE_SUB(NOW(), INTERVAL 24 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003013', '00000000-0000-4000-8000-000000000203', '00000000-0000-4000-8000-000000000303', 'page_form', 'blk_form',
  '{"姓名": "沈星野", "手机号": "13810000013", "学院班级": "计算机 2305"}', '00000000-0000-4000-8000-000000005013', 'f01ca4e03dd316fc0be13b9eb4df8a1aa39464a272c2681a40dc108ba52b8173', 'valid', DATE_SUB(NOW(), INTERVAL 31 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003014', '00000000-0000-4000-8000-000000000203', '00000000-0000-4000-8000-000000000303', 'page_form', 'blk_form',
  '{"姓名": "韩其琛", "手机号": "13810000014", "学院班级": "计算机 2306"}', '00000000-0000-4000-8000-000000005014', '19dc3850c88e191207fd9b58401f9fe8fcdca18c9035a6df965c332c31b9e6e8', 'valid', DATE_SUB(NOW(), INTERVAL 38 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003015', '00000000-0000-4000-8000-000000000204', '00000000-0000-4000-8000-000000000304', 'page_form', 'blk_form',
  '{"姓名": "杨以宁", "手机号": "13810000015", "学院班级": "计算机 2301"}', '00000000-0000-4000-8000-000000005015', '73f952a6e39423ea9284c54ebf92626fa0fbc53c71a437a3f17f933dd5058cde', 'valid', DATE_SUB(NOW(), INTERVAL 4 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003016', '00000000-0000-4000-8000-000000000204', '00000000-0000-4000-8000-000000000304', 'page_form', 'blk_form',
  '{"姓名": "朱静川", "手机号": "13810000016", "学院班级": "计算机 2302"}', '00000000-0000-4000-8000-000000005016', '97f83be9b64d3139af3f803c7f0fae6d9d29c37fff80ba5e5508ada26d362ae9', 'valid', DATE_SUB(NOW(), INTERVAL 11 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003017', '00000000-0000-4000-8000-000000000204', '00000000-0000-4000-8000-000000000304', 'page_form', 'blk_form',
  '{"姓名": "秦望舒", "手机号": "13810000017", "学院班级": "计算机 2303"}', '00000000-0000-4000-8000-000000005017', 'd6bb358c15252225af9119cda6751db8619c5490670db723d4f3bb46c793a46f', 'valid', DATE_SUB(NOW(), INTERVAL 18 HOUR))
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES ('00000000-0000-4000-8000-000000003018', '00000000-0000-4000-8000-000000000204', '00000000-0000-4000-8000-000000000304', 'page_form', 'blk_form',
  '{"姓名": "李思远", "手机号": "13810000018", "学院班级": "计算机 2304"}', '00000000-0000-4000-8000-000000005018', 'e633e20895623c79d6fbf278e3ac25b93e45e4a37889b2aa3c5fecce87883cc8', 'valid', DATE_SUB(NOW(), INTERVAL 25 HOUR))
ON DUPLICATE KEY UPDATE id = id;

-- ---------------------------------------------------------------- 4) 行为事件（统计页要用）

DELETE FROM activity_events WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, '$.demo')) = 'true';

INSERT INTO activity_events (project_id, event_type, page_id, metadata, occurred_at) VALUES
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000202', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000203', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'public_page_view', 'page_home', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000204', 'form_started', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 0 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  ('00000000-0000-4000-8000-000000000201', 'submission_succeeded', 'page_form', '{"demo": true}', DATE_SUB(NOW(), INTERVAL 2 DAY));


-- ---------------------------------------------------------------- 5) AI 任务与提案（人在环演示）

INSERT INTO ai_jobs (id, project_id, user_id, kind, status, client_request_id,
  input_payload, result_payload, model_provider, model_name, started_at, finished_at)
VALUES ('00000000-0000-4000-8000-000000006001', '00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000001', 'generate_from_prompt', 'succeeded', 'demo-job-1',
  '{"prompt": "摄影社招新，11月8日晚7点在三教402面试，招60人"}', '{"proposals": 1}', 'deepseek', 'deepseek-chat',
  DATE_SUB(NOW(), INTERVAL 26 HOUR), DATE_SUB(NOW(), INTERVAL 26 HOUR))
ON DUPLICATE KEY UPDATE status = 'succeeded';

INSERT INTO ai_proposals (id, job_id, project_id, base_version_id, base_revision, target, summary,
  candidate_document, operations, rationale, risk, status)
VALUES ('00000000-0000-4000-8000-000000006002', '00000000-0000-4000-8000-000000006001', '00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000301', 1, '{"pageId": "page_home", "blockId": "blk_banner"}',
  '副标题补上「每周三晚外拍」，让招新页更有信息量', NULL, '[{"op": "replace", "path": "pages[0].blocks[1].props.subtitle", "before": "2026 秋季招新", "after": "2026 秋季招新 · 每周三晚外拍"}]', '["副标题补上活动频率，让招新海报更有说服力", "依据：知识库《社团招新页面方案》建议副标题写清来了能干什么"]', 'low', 'proposed')
ON DUPLICATE KEY UPDATE summary = VALUES(summary);

-- ---------------------------------------------------------------- 6) 导出任务

INSERT INTO export_jobs (id, project_id, requested_by, status, filters, object_key, expires_at, finished_at)
VALUES ('00000000-0000-4000-8000-000000007001', '00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000001', 'succeeded', '{"status": "valid"}',
  'exports/photo-club-2026-20261029.csv', DATE_ADD(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 20 HOUR))
ON DUPLICATE KEY UPDATE id = id;

-- ---------------------------------------------------------------- 3b) 投票项目的提交记录
-- 投票也是一次"提交"，不给它塞几条，点开"提交数据"就是空白。

INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
  answers, idempotency_key, submitter_hash, status, submitted_at)
VALUES
  ('00000000-0000-4000-8000-000000003101', '00000000-0000-4000-8000-000000000202', '00000000-0000-4000-8000-000000000302', 'page_form', 'blk_form', '{"你的一票投给谁": "01 号 李同学", "你的学院": "工学院"}', '00000000-0000-4000-8000-000000005101', 'a1b2c3d4', 'valid', DATE_SUB(NOW(), INTERVAL 30 HOUR)),
  ('00000000-0000-4000-8000-000000003102', '00000000-0000-4000-8000-000000000202', '00000000-0000-4000-8000-000000000302', 'page_form', 'blk_form', '{"你的一票投给谁": "02 号 王同学", "你的学院": "文学院"}', '00000000-0000-4000-8000-000000005102', 'b2c3d4e5', 'valid', DATE_SUB(NOW(), INTERVAL 27 HOUR)),
  ('00000000-0000-4000-8000-000000003103', '00000000-0000-4000-8000-000000000202', '00000000-0000-4000-8000-000000000302', 'page_form', 'blk_form', '{"你的一票投给谁": "03 号 张同学", "你的学院": "理学院"}', '00000000-0000-4000-8000-000000005103', 'c3d4e5f6', 'valid', DATE_SUB(NOW(), INTERVAL 22 HOUR)),
  ('00000000-0000-4000-8000-000000003104', '00000000-0000-4000-8000-000000000202', '00000000-0000-4000-8000-000000000302', 'page_form', 'blk_form', '{"你的一票投给谁": "01 号 李同学", "你的学院": "工学院"}', '00000000-0000-4000-8000-000000005104', 'd4e5f6a7', 'valid', DATE_SUB(NOW(), INTERVAL 14 HOUR)),
  ('00000000-0000-4000-8000-000000003105', '00000000-0000-4000-8000-000000000202', '00000000-0000-4000-8000-000000000302', 'page_form', 'blk_form', '{"你的一票投给谁": "02 号 王同学", "你的学院": "工学院"}', '00000000-0000-4000-8000-000000005105', 'e5f6a7b8', 'valid', DATE_SUB(NOW(), INTERVAL 9 HOUR)),
  ('00000000-0000-4000-8000-000000003106', '00000000-0000-4000-8000-000000000202', '00000000-0000-4000-8000-000000000302', 'page_form', 'blk_form', '{"你的一票投给谁": "03 号 张同学", "你的学院": "艺术学院"}', '00000000-0000-4000-8000-000000005106', 'f6a7b8c9', 'valid', DATE_SUB(NOW(), INTERVAL 3 HOUR))
ON DUPLICATE KEY UPDATE id = id;

-- 自检：
--   SELECT id, title, status, public_slug FROM projects;
--   SELECT project_id, COUNT(*) FROM form_submissions GROUP BY project_id;
--   SELECT project_id, event_type, COUNT(*) FROM activity_events GROUP BY project_id, event_type;
