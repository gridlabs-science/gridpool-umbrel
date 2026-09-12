#!/bin/sh
set -eu

setup_override=/shared/boot_portal_config.local.json

setup_is_complete() {
  [ -s "${setup_override}" ] &&
    grep -q '"setup_completed"[[:space:]]*:[[:space:]]*true' "${setup_override}" &&
    grep -q '"pool_payout_script"[[:space:]]*:[[:space:]]*"[^\"]\+"' "${setup_override}"
}

cd /app

if setup_is_complete; then
  exec dotnet boot_portal.dll
fi

dotnet boot_portal.dll &
gridpool_pid=$!

stop_gridpool() {
  kill -TERM "${gridpool_pid}" 2>/dev/null || true
  wait "${gridpool_pid}" 2>/dev/null || true
}

trap stop_gridpool INT TERM

while kill -0 "${gridpool_pid}" 2>/dev/null; do
  if setup_is_complete; then
    echo "GridPool payout address saved; restarting into operational mode."
    stop_gridpool
    exec dotnet boot_portal.dll
  fi
  sleep 1
done

wait "${gridpool_pid}"
