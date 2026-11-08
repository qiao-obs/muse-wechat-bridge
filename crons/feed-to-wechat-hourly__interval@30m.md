---
id: feed-to-wechat-hourly
title: 动态同步到微信（每30分钟）
enabled: true
owner: goal:wechat-bridge-wx-bot-integration
mode: task
schedule:
  kind: interval
  timezone: Asia/Shanghai
  at: 2026-10-26T14:35:47
  every: 30m
delivery:
  - chat_id: 23eab801-0fb6-4d0a-a541-f393ae89444b
metadata:
  tags: [cron:automatic-interval-anchor]
  originating_chat_context_json: '{"chat_id":"23eab801-0fb6-4d0a-a541-f393ae89444b","origin_provider":"main","chat_kind":"direct","event_kind":"message","require_mention":false}'
  presentation_locale: zh-CN
---
Hourly Feed-to-WeChat trigger, now every 30 minutes for faster dynamic monitoring. You are only a trigger; do not do anything else.

- Do NOT call any feed tools (feed.unit_list, feed.unit_get, feed.search, and the other feed unit tools only work in the main conversation and will fail in this scheduled run). Do NOT send anything to WeChat yourself.
- Do NOT write any report files. Do NOT edit MEMORY.md.
- Your entire job is to deliver exactly this message to the main chat: "Hourly Feed-to-WeChat check is due. Please list recent feed units, compare them with ~/workspace/goals/wechat-bridge-wx-bot-integration/hidden_files/feed-forwarded.json, forward any unit not in that list to the user's WeChat via wx-bot send (plain text: title plus body with links written out as plain URLs; if the unit has a stored hero media file, send it with --image as well), append the forwarded unit_ids to the state file, and stay silent in main chat unless a forward failed."
