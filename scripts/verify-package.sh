#!/usr/bin/env bash
set -euo pipefail

compose="gridlabs-gridpool/docker-compose.yml"
template="gridlabs-gridpool/templates/boot_portal_config.json.template"

for script in gridlabs-gridpool/templates/*.sh; do sh -n "$script"; done
ruby -e 'require "yaml"; YAML.load_file(ARGV[0])' "$compose"
ruby -e 'require "yaml"; YAML.load_file(ARGV[0])' gridlabs-gridpool/umbrel-app.yml

references="$(grep -oE 'ghcr\.io/[^ @]+@sha256:[0-9a-f]{64}' "$compose" | sort -u)"
[[ "$(printf '%s\n' "$references" | sed '/^$/d' | wc -l)" -eq 2 ]]
! grep -Eq 'image: .*:sha-' "$compose"

grep -q '"enable_legacy_ui": false' "$template"
grep -q '"enable_admin_api": false' "$template"
! grep -q 'env_file' "$compose"
! grep -Eq '(^|[[:space:]])(8332|28332|28333|34290|5000):' "$compose"
grep -q '34265:34265/tcp' "$compose"
grep -q '5001:5001/udp' "$compose"

for reference in $references; do
  if command -v docker >/dev/null 2>&1; then
    inspection="$(docker buildx imagetools inspect "$reference")"
    grep -q 'linux/amd64' <<<"$inspection"
    grep -q 'linux/arm64' <<<"$inspection"
  fi
done

echo "Umbrel package contract and immutable release inputs verified"
