#!/usr/bin/env bash
# Hook detector: wx-bot (WeChat bridge, binding=muse, pull delivery).
# Polls the local inbox; wakes a worker when new WeChat events arrive,
# or when the wx-bot service itself is down/stuck.
#
# - `inbox count` only counts claimable events: no side effects, dry-run safe.
# - Events being processed are leased (invisible to count), so a working
#   agent is not woken again; unacked events return after lease expiry.
# - Alerts (disconnects, expired login) arrive as inbox events and are counted.
# - `health --liveness` covers the one thing alerts cannot: wx-bot run itself
#   being down. Same problem wakes at most once per hour.
set -euo pipefail
source "$HATCH_HOOK_RUNTIME"

WXBOT="${WXBOT:-$HOME/.local/bin/wx-bot}"
BINDING="${WXBOT_BINDING:-muse}"
MARK="$HOME/.cache/wx-bot/hook-alerted"
# Wake cooldown: when new events arrive, the first worker takes a while to
# start up and lease them, so count stays > 0 across several polls and the
# old code woke a worker on EVERY poll (e.g. 5 wakes for 2 events on
# 2026-10-25 12:31). Suppress re-wakes for the same unchanged count within
# 120s; a changed count (new events) or a zero count (all leased/handled)
# always wakes fresh. Worst case if the first worker dies before pulling:
# the next wake comes at most 120s later.
WAKE_STATE="$HOME/.cache/wx-bot/hook-last-wake"

# Auto-recover from VM replacement: every VM swap wipes /etc, deleting the
# systemd unit, while home (binary, config, backup) survives. A missing unit
# file is the VM-wipe signature: stopping the service by hand leaves the unit
# in place, and intentional uninstall is marked separately. Only restore when
# the unit is missing AND no uninstall marker exists. A merely stopped service
# (unit present) is never restarted here; that stays a worker decision.
UNIT="/etc/systemd/system/wx-bot.service"
BACKUP="$HOME/workspace/wx-bot-deploy/wx-bot.service"
UNINSTALLED="$HOME/workspace/wx-bot-deploy/.uninstalled"
if [ ! -f "$UNIT" ] && [ ! -f "$UNINSTALLED" ] && [ -f "$BACKUP" ]; then
  if [ "${HATCH_HOOK_DRY_RUN:-0}" = "1" ]; then
    log "dry run：检测到服务文件缺失，正式运行时将自动恢复" "{}"
  else
    log "服务文件缺失（虚拟机更换），正在从备份恢复" "{}"
    if sudo -n cp "$BACKUP" "$UNIT" && sudo -n systemctl daemon-reload; then
      sudo -n systemctl enable wx-bot >/dev/null 2>&1 || true
      if sudo -n systemctl start wx-bot; then
        restored_ok=0
        for _ in 1 2 3 4; do
          if "$WXBOT" health --binding "$BINDING" --liveness >/dev/null 2>&1; then
            restored_ok=1
            break
          fi
          sleep 3
        done
        if [ "$restored_ok" = "1" ]; then
          rm -f "$MARK"
          log "服务文件已自动恢复，服务正常" "{}"
          silent "wx-bot 服务文件缺失已自动恢复，服务正常"
        fi
      fi
    fi
    log "服务文件自动恢复未成功，转入异常提醒流程" "{}"
  fi
fi

count_raw="$("$WXBOT" inbox count --binding "$BINDING" 2>&1)" || {
  silent "wx-bot inbox count 执行失败" "{\"error\": $(printf '%s' "$count_raw" | jq -Rs .)}"
}
count="$(printf '%s' "$count_raw" | tr -cd '0-9')"
if [ -z "$count" ]; then
  silent "wx-bot inbox count 输出无法解析" "{\"output\": $(printf '%s' "$count_raw" | jq -Rs .)}"
fi
if [ "$count" -gt 0 ]; then
  now_epoch="$(date +%s)"
  last_count=""
  last_wake=""
  if [ -f "$WAKE_STATE" ]; then
    read -r last_count last_wake < "$WAKE_STATE" 2>/dev/null || true
  fi
  if [ -n "$last_wake" ] && [ "$last_count" = "$count" ] && [ $((now_epoch - last_wake)) -lt 120 ]; then
    silent "新微信事件已在2分钟内唤醒过，等待处理中，不重复唤醒" "{\"count\": $count}"
  else
    log "wechat new events" "{\"count\": $count}"
    if [ "${HATCH_HOOK_DRY_RUN:-0}" != "1" ]; then
      printf '%s %s\n' "$count" "$now_epoch" > "$WAKE_STATE"
    fi
    wake "微信有 $count 条新事件" "{\"count\": $count, \"binding\": \"$BINDING\"}"
  fi
else
  rm -f "$WAKE_STATE"
fi

if health_out="$("$WXBOT" health --binding "$BINDING" --liveness 2>&1)"; then
  rm -f "$MARK"
  silent "无新微信事件，wx-bot 服务正常"
fi
# health failed: throttle repeated wakes to once per hour per problem
if [ -f "$MARK" ] && [ -z "$(find "$MARK" -mmin +60 2>/dev/null)" ]; then
  silent "wx-bot 异常已在1小时内提醒过，不重复唤醒"
fi
mkdir -p "$(dirname "$MARK")"
touch "$MARK"
log "wx-bot unhealthy" "{\"health\": $(printf '%s' "$health_out" | jq -Rs .)}"
wake "wx-bot 异常：服务未运行或卡住" "{\"health\": $(printf '%s' "$health_out" | jq -Rs .)}"
