#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DISK_THRESHOLD=${DISK_THRESHOLD:-90}
DRY_RUN=${DRY_RUN:-0}
LOG_FILE=${LOG_FILE:-"${SCRIPT_DIR}/logs/app.log"}
CONF_TEMPLATE="${SCRIPT_DIR}/app_logrotate.conf"

if ! [[ "${DISK_THRESHOLD}" =~ ^[0-9]+$ ]] || (( DISK_THRESHOLD < 0 || DISK_THRESHOLD > 100 )); then
  echo "[ERROR] DISK_THRESHOLD must be an integer from 0 to 100." >&2
  exit 2
fi

if [[ ! -f "${CONF_TEMPLATE}" ]]; then
  echo "[ERROR] Missing logrotate template: ${CONF_TEMPLATE}" >&2
  exit 2
fi

current_disk=$(df -P / | awk 'NR == 2 {gsub(/%/, "", $5); print $5}')

if ! [[ "${current_disk}" =~ ^[0-9]+$ ]]; then
  echo "[ERROR] Could not determine root-filesystem usage." >&2
  exit 2
fi

printf '[MONITOR] %s - Root filesystem usage: %s%% (threshold: %s%%)\n' \
  "$(date '+%Y-%m-%d %H:%M:%S')" "${current_disk}" "${DISK_THRESHOLD}"

if (( current_disk < DISK_THRESHOLD )); then
  echo "[HEALTHY] Disk usage is below the rotation threshold."
  exit 0
fi

if ! command -v logrotate >/dev/null 2>&1; then
  echo "[ERROR] logrotate is not installed or not available in PATH." >&2
  exit 3
fi

runtime_conf=$(mktemp)
trap 'rm -f "${runtime_conf}"' EXIT

awk -v log_path="${LOG_FILE}" \
  '{gsub(/__LOG_FILE__/, log_path); print}' \
  "${CONF_TEMPLATE}" > "${runtime_conf}"

echo "[WARNING] Threshold reached; emergency log rotation requested."

if [[ "${DRY_RUN}" == "1" ]]; then
  echo "[DRY RUN] Would run: sudo logrotate -f ${runtime_conf}"
  echo "[DRY RUN] Rendered configuration:"
  cat "${runtime_conf}"
  exit 0
fi

sudo logrotate -f "${runtime_conf}"
echo "[SUCCESS] Emergency log rotation completed."
