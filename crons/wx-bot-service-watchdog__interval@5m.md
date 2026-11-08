---
id: wx-bot-service-watchdog
title: wx-bot 服务看门狗（每5分钟）
enabled: true
owner: goal:wechat-bridge-wx-bot-integration
mode: task
schedule:
  kind: interval
  timezone: Asia/Shanghai
  at: 2026-10-26T11:25:16
  every: 5m
timeout_secs: 300
metadata:
  tags: [cron:automatic-interval-anchor]
  originating_chat_context_json: '{"chat_id":"23eab801-0fb6-4d0a-a541-f393ae89444b","origin_provider":"main","chat_kind":"direct","event_kind":"message","require_mention":false,"device_id":"a08bcf0e5031283a"}'
  presentation_locale: zh-CN
---
微信桥 wx-bot 服务看门狗：虚拟机更换会抹掉 /etc 下文件，之前已因此丢失过两次服务文件。每次运行做以下检查（保持安静，无变化则不报告）：

1. 如果存在 `<home>/workspace/wx-bot-deploy/.uninstalled` 标记文件，说明用户已主动卸载，直接退出，不做任何操作。
2. 检查 `/etc/systemd/system/wx-bot.service` 是否存在。若缺失，从 canonical 备份 `<home>/workspace/wx-bot-deploy/wx-bot.service` 复制过去，然后 `systemctl daemon-reload`、`systemctl enable wx-bot`。
3. 检查服务状态：`systemctl is-active wx-bot`。若非 active，执行 `systemctl start wx-bot`，并在启动后再次确认状态。
4. 只有当本次实际恢复了文件、enable 或启动了服务时，才在运行结果中说明做了什么；无变化时保持安静、不发通知。

说明：本任务频率已从每小时改为每10分钟、再改为每5分钟，目的是在虚拟机更换后更快恢复服务，检查内容不变；仍不能缩短虚拟机更换本身造成的轮询停滞窗口。
