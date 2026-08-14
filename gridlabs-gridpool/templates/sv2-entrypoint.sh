#!/bin/sh
set -eu

setup_override=/shared/boot_portal_config.local.json

while :; do
  if [ -s "${setup_override}" ] &&
     grep -q '"setup_completed"[[:space:]]*:[[:space:]]*true' "${setup_override}"; then
    payout_address="$(sed -n 's/.*"pool_payout_script"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "${setup_override}" | head -n 1)"
    if [ -n "${payout_address}" ]; then
      break
    fi
  fi
  echo "Native SV2 is waiting for the GridPool payout address to be saved in the app."
  sleep 5
done

case "${payout_address}" in
  bc1*|1*|3*) ;;
  *) echo "Persisted GridPool payout address is not a supported mainnet address" >&2; exit 1 ;;
esac

set -a
. /data/authority.env
set +a

export GRIDPOOL_PAYOUT_ADDRESS="${payout_address}"
export BITCOIN_RPC_URL="http://${APP_BITCOIN_NODE_IP}:${APP_BITCOIN_RPC_PORT}"

umask 077
temporary_config=/data/pool-config.toml.tmp
envsubst < /templates/pool-config.toml.template > "${temporary_config}"
mv "${temporary_config}" /data/pool-config.toml

echo "Starting native SV2 with the payout address saved through GridPool setup."
exec /app/pool_sv2 --config /data/pool-config.toml
