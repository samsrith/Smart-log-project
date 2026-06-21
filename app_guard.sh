#!/bin/bash

# Define thresholds and paths
DISK_THRESHOLD=90
CONF_PATH="/home/sam/smart-log-project/app_logrotate.conf"

# Use df -h paired with awk to isolate the disk utilization number of the root drive
CURRENT_DISK=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

echo "[MONITOR] $(date '+%Y-%m-%d %H:%M:%S') - Checking storage status... Current Usage: ${CURRENT_DISK}%"

# Check if current usage hits our danger threshold
if [ "$CURRENT_DISK" -gt "$DISK_THRESHOLD" ]; then
    echo "[WARNING] Disk consumption has breached ${DISK_THRESHOLD}%! Launching emergency log rotation..."
    sudo logrotate -f "$CONF_PATH"
    echo "[SUCCESS] Emergency cleanup complete."
else
    echo "[HEALTHY] Storage utilization is within safe operational parameters."
fi
