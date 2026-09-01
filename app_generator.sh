#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
LOG_FILE=${LOG_FILE:-"${SCRIPT_DIR}/logs/app.log"}
LOG_INTERVAL=${LOG_INTERVAL:-0.2}

mkdir -p "$(dirname -- "${LOG_FILE}")"

shutdown() {
  printf '\n[INFO] Generator stopped. Log file: %s\n' "${LOG_FILE}"
}
trap shutdown EXIT
trap 'exit 0' INT TERM

printf '[INFO] %s - Starting sample application service.\n' \
  "$(date '+%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"

while true; do
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  user_id=$((RANDOM % 9000 + 1000))
  transaction_id=$((RANDOM % 90000 + 10000))
  cents=$((RANDOM % 90 + 10))

  printf '[INFO] %s - USER_LOGIN - User ID %s authenticated.\n' \
    "${timestamp}" "${user_id}" >> "${LOG_FILE}"
  printf '[SUCCESS] %s - PAYMENT_API - Transaction TXN%s processed. Amount: $12.%s\n' \
    "${timestamp}" "${transaction_id}" "${cents}" >> "${LOG_FILE}"

  if (( RANDOM % 5 == 0 )); then
    printf '[WARNING] %s - DB_CONNECTION - Simulated latency spike detected.\n' \
      "${timestamp}" >> "${LOG_FILE}"
  fi

  sleep "${LOG_INTERVAL}"
done
