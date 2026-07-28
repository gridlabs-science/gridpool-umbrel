#!/bin/sh
set -eu

case "${GRIDPOOL_PAYOUT_ADDRESS:-}" in
  bc1*|1*|3*) ;;
  *) echo "GRIDPOOL_PAYOUT_ADDRESS must be a mainnet Bitcoin address" >&2; exit 1 ;;
esac

mkdir -p /data/gridpool /data/sv2/proof-spool /data/shared
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
envsubst < /templates/pool-config.toml.template > /data/sv2/pool-config.toml
chmod 600 /data/gridpool/boot_portal_config.json /data/sv2/authority.env /data/sv2/pool-config.toml /data/shared/local-adapter.token
chown -R 1000:1000 /data/gridpool /data/shared
