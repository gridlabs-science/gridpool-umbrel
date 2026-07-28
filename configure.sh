#!/usr/bin/env bash
set -euo pipefail

address="${1:-}"
if [[ ! "${address}" =~ ^(bc1|1|3)[A-Za-z0-9]{20,90}$ ]]; then
  echo "Usage: $0 MAINNET_BITCOIN_ADDRESS" >&2
  exit 1
fi

settings="$(dirname "$0")/gridpool/settings.env"
printf 'GRIDPOOL_PAYOUT_ADDRESS=%s\n' "${address}" > "${settings}"
chmod 600 "${settings}"
echo "Configured ${settings}. Do not commit this local file."
