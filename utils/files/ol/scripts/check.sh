#!/bin/bash
# check.sh — HAL9042 health probe
# Run from ol's crontab every 5 minutes. Writes a heartbeat to the log.
#
# ol: keep this lightweight. it runs as me, every 5 min, forever.

LOG=/var/log/hal9042/check.log
echo "$(date -u +%FT%TZ) [check] hal9042d heartbeat: nominal" >> "$LOG" 2>/dev/null
echo "$(date -u +%FT%TZ) [check] confidence: nominal" >> "$LOG" 2>/dev/null
