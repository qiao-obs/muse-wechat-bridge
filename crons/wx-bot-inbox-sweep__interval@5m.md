---
id: wx-bot-inbox-sweep
title: 微信收件箱扫表（每5分钟，只计数）
enabled: true
owner: goal:wechat-bridge-wx-bot-integration
mode: task
schedule:
  kind: interval
  timezone: Asia/Shanghai
  at: 2026-10-26T11:25:23
  every: 5m
delivery:
  - chat_id: 23eab801-0fb6-4d0a-a541-f393ae89444b
metadata:
  tags: [cron:automatic-interval-anchor]
  originating_chat_context_json: '{"chat_id":"23eab801-0fb6-4d0a-a541-f393ae89444b","origin_provider":"main","chat_kind":"direct","event_kind":"message","require_mention":false,"device_id":"a08bcf0e5031283a"}'
  presentation_locale: zh-CN
---
微信收件箱第二唤醒路径（只计数、不抢消息）：

1. 运行 ~/.local/bin/wx-bot inbox count --binding muse，只计数，不 pull，不确认，不发微信。
2. 如果计数为 0，保持安静，不报告。
3. 如果计数大于 0，在运行结果中说明：收件箱有 N 条未处理消息，hook 轮询可能延迟，主聊应按主聊处理模式拉取并处理（先查快照、对话记录、图片索引和任务状态，按 event_id 去重；如果记录里没有已发快速确认，就由主聊补发收到确认加正式回复；回复完再确认消息）。

注意：本任务只做计数触发，不直接拉取、不直接回复，避免和 hook 抢同一条消息的租约。
