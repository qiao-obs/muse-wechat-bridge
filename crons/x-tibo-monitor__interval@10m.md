---
id: x-tibo-monitor
title: X 上 Tibo 帖子监测（自适应，Pepper 规则）
enabled: true
owner: goal:wechat-bridge-wx-bot-integration
mode: task
schedule:
  kind: interval
  timezone: Asia/Shanghai
  at: 2026-10-26T14:21:10
  every: 10m
delivery:
  - chat_id: 23eab801-0fb6-4d0a-a541-f393ae89444b
metadata:
  tags: [cron:automatic-interval-anchor]
  originating_chat_context_json: '{"chat_id":"23eab801-0fb6-4d0a-a541-f393ae89444b","origin_provider":"main","chat_kind":"direct","event_kind":"message","require_mention":false}'
  presentation_locale: zh-CN
---
监测 X 上 Tibo 的新帖子，账号是 @thsottiaux（Thibault Sottiaux，OpenAI Codex 和 ChatGPT 负责人），参考时间线 https://willreset.com/tibo 和 X 搜索。自适应规则按 Pepper AI 截图执行：平时每 10 分钟采集；出现可信暗示或预告后每 5 分钟；临近预告时间每 2 分钟；确认落地或观察窗口结束后完全停止采集 12 小时，期间不请求 X／聚合源、不唤醒 AI，到期自动恢复常态采集；窗口结束但没有确认只记为“未确认”，不会当作已到账，冷却时间也不会被重复检查不断顺延；观察窗口默认在最晚预告期限后 1 小时结束，没有明确期限时最多观察 2 小时。

每次运行只做检查触发，不直接发微信：先读 ~/workspace/goals/wechat-bridge-wx-bot-integration/hidden_files/x-tibo-seen.json 和 ~/workspace/goals/wechat-bridge-wx-bot-integration/hidden_files/monitoring-core-state.md，检查是否在 12 小时冷却期内（在冷却期内保持安静，不检查）；比较最新帖子与已记录的最新帖子；如果没有新帖，保持安静，不报告；如果有新帖，在运行结果中说明新帖的原文、链接、时间、是否属于可信暗示或预告、有无明确期限，并请主聊处理：主聊要把原文翻译成中文，尽量附截图，然后发到用户的微信，并更新已记录的最新帖子、观察窗口和冷却时间，不要重复发旧帖。重置类帖子优先立即通知。
