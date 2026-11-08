---
id: aihot-wechat-push
title: AIHOT 资讯推送（每2小时）
enabled: true
owner: goal:wechat-bridge-wx-bot-integration
mode: task
schedule:
  kind: interval
  timezone: Asia/Shanghai
  at: 2026-11-07T17:45:19
  every: 2h
delivery:
  - chat_id: 23eab801-0fb6-4d0a-a541-f393ae89444b
metadata:
  tags: [cron:automatic-interval-anchor]
  originating_chat_context_json: '{"chat_id":"23eab801-0fb6-4d0a-a541-f393ae89444b","origin_provider":"main","chat_kind":"direct","event_kind":"message","require_mention":false}'
  presentation_locale: zh-CN
---
每 2 小时检查一次 AIHOT 精选 RSS（https://aihot.news/feed.xml），有新资讯就报给主聊推到用户微信，没更新不打扰。

每次运行只做检查触发，不直接发微信：先读 ~/workspace/goals/wechat-bridge-wx-bot-integration/hidden_files/aihot-seen.json（seen 里是已处理过的条目链接），用 curl 拉取 RSS（curl 失败则改用浏览器打开该地址读文本），解析出全部 item（link、title、pubDate、description 首行）；把 link 不在 seen 里的条目列为新资讯。如果没有新资讯，保持安静，不报告，只把检查记到 ~/memory/2026-11-07.md 这类当日日志里。如果有新资讯，在运行结果中逐条说明新资讯的标题、链接、发布时间和描述首行，并请主聊处理：主聊核对后把新资讯合成一条消息发到用户微信（标题加链接，每条一行，附“微信推送｜AI 资讯更新”抬头），只有实际发送成功后才把条目记入 seen；不要逐条发多条消息，不要补发基线之前的旧资讯。推送只在 09:00–21:30 之间发，窗口外只记录不发送，留待窗口内再推。

不要自己发微信，不要改 MEMORY.md，不要写报告文件到 files/。
