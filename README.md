# Muse × 微信桥接系统

把个人 AI 助手（Muse）接到自己的微信里：微信消息经 wx-bot 落到本机收件箱，助手拉取处理，再发回微信。主聊是唯一处理源，微信侧只做转发和快速确认。

> 来源：2026-10-15 至 2026-11-07 在一台 Linux 虚拟机上真实跑通的记录。完整搭建步骤见 `docs/微信桥接搭建手册（合并版）.md`；这里只放代码和配置模板。

## 仓库里有什么

| 目录 | 内容 |
|---|---|
| `docs/` | 搭建手册（合并版，朋友整理）与 WSL2 版补充 |
| `install/` | systemd 服务文件、`config.example.json`、`env.example`（代理模板） |
| `hooks/` | 微信唤醒 hook：`wechat-wxbot.sh`（5 秒轮询）与定义 `wechat-wxbot.json` |
| `crons/` | 5 个定时任务定义：动态同步、Tibo 监测、AIHOT 资讯推送、收件箱扫表、服务看门狗 |

## 快速开始

1. 按上游安装 wx-bot：https://github.com/lawrencewzen/wx-bot（wx-bot 本身不在本仓库，只引用；支持 Linux 与 macOS，不支持 Windows，Windows 请看 `docs/` 里的 WSL2 补充）。
2. 复制 `install/config.example.json` 为 `~/.config/wx-bot/config.json`，把 `<...>` 占位符换成你自己的值（token 随机生成，只存本机）。
3. 有代理才需要 `install/env.example`，复制为 `~/.config/wx-bot/env` 并填你自己的代理地址。
4. 把 `install/wx-bot.service` 里的 `<home>` 换成你的 home，装到 `/etc/systemd/system/wx-bot.service`，启动服务。
5. `wx-bot login <binding> --qr-png <文件> --timeout 10m` 扫码登录。
6. 按手册第 9–12 节接 hook 与主聊处理模式，再按需启用 `crons/` 里的定时任务。

## 占位符约定

- `<home>`：你的 home 绝对路径
- `<binding>`：你的 binding 名
- `<助手名>` / `<用户名>`：你的助手名和你的名字
- `<你的微信号>`：运行时用 `wx-bot status` 查看

## 脱敏说明

本仓库不含任何真实凭据：没有密码、令牌、密钥、微信号和代理地址。`config.json` 只提供模板（`config.example.json`），真实 token 只存在本机。`.gitignore` 已排除 `config.json`、`env` 与运行状态。发布前请再自行检查一遍。

## 已知局限

- 发送通道曾长期返回 HTTP 502（上游 iLink 网关问题），手册第 16 节有处置办法。
- 虚拟机更换会清空 `/etc`，hook 脚本里有从备份自动恢复服务文件的逻辑。
- 工具调用类任务的端到端、重启持久性、去重、登录过期提醒尚未正式验收（手册里标“未验证”的就是）。

## License

MIT
