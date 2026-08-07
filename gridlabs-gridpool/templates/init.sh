#!/bin/sh
set -eu

mkdir -p /data/gridpool /data/sv2/proof-spool /data/shared
setup_override=/data/shared/boot_portal_config.local.json
payout_address="${GRIDPOOL_PAYOUT_ADDRESS:-}"
configured_from_environment=false

if [ -n "${payout_address}" ]; then
  configured_from_environment=true
fi

if [ -z "${payout_address}" ] && [ -s "${setup_override}" ]; then
  payout_address="$(sed -n 's/.*"pool_payout_script"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "${setup_override}" | head -n 1)"
fi

if [ -n "${payout_address}" ]; then
  case "${payout_address}" in
    bc1*|1*|3*) ;;
    *) echo "GRIDPOOL_PAYOUT_ADDRESS must be a mainnet Bitcoin address" >&2; exit 1 ;;
  esac

  if [ "${configured_from_environment}" = true ] && [ -s "${setup_override}" ]; then
    umask 077
    temporary_override="${setup_override}.tmp"
    sed "s#\"pool_payout_script\"[[:space:]]*:[[:space:]]*\"[^\"]*\"#\"pool_payout_script\": \"${payout_address}\"#" \
      "${setup_override}" > "${temporary_override}"
    updated_address="$(sed -n 's/.*"pool_payout_script"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "${temporary_override}" | head -n 1)"
    if [ "${updated_address}" != "${payout_address}" ]; then
      echo "Could not update the persisted GridPool payout address safely" >&2
      exit 1
    fi
    mv "${temporary_override}" "${setup_override}"
  fi
fi

export GRIDPOOL_PAYOUT_ADDRESS="${payout_address}"

if [ ! -s /data/shared/local-adapter.token ]; then
  umask 077
  head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' > /data/shared/local-adapter.token
fi

if [ ! -s /data/sv2/authority.env ]; then
  umask 077
  /app/pool_sv2 --generate-authority-keypair > /data/sv2/authority.env
fi

set -a
. /data/sv2/authority.env
set +a

export BITCOIN_RPC_URL="http://${APP_BITCOIN_NODE_IP}:${APP_BITCOIN_RPC_PORT}"
export BITCOIN_ZMQ_HASHBLOCK="tcp://${APP_BITCOIN_NODE_IP}:${APP_BITCOIN_ZMQ_HASHBLOCK_PORT}"
export BITCOIN_ZMQ_RAWBLOCK="tcp://${APP_BITCOIN_NODE_IP}:${APP_BITCOIN_ZMQ_RAWBLOCK_PORT}"
envsubst < /templates/boot_portal_config.json.template > /data/gridpool/boot_portal_config.json
if [ -n "${GRIDPOOL_PAYOUT_ADDRESS}" ]; then
  envsubst < /templates/pool-config.toml.template > /data/sv2/pool-config.toml
else
  rm -f /data/sv2/pool-config.toml
  echo "GridPool payout address is not configured; starting the reference node in setup-only mode."
fi

chmod 600 /data/gridpool/boot_portal_config.json /data/sv2/authority.env /data/shared/local-adapter.token
if [ -f "${setup_override}" ]; then
  chmod 600 "${setup_override}"
fi
if [ -f /data/sv2/pool-config.toml ]; then
  chmod 600 /data/sv2/pool-config.toml
fi
chown -R 1000:1000 /data/gridpool /data/shared
