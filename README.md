# GridPool for Umbrel

Community-app wrapper for the GridPool reference node and its canonical native
Stratum V2 server. The package uses Umbrel's installed Bitcoin implementation
through the generic RPC/ZMQ exports, so either Bitcoin Core or Bitcoin Knots can
provide the backend.

This is a sideload beta. The application UI remains behind Umbrel
authentication, the node participates outbound-only by default, and only the
SV2 miner port plus the UDP peer-relay port are published.

The wrapper pins immutable, attested multi-architecture OCI image digests. It
does not follow a mutable branch or `latest` image.

## Configure and install

Clone and install the package, then open GridPool from the Umbrel dashboard. On
first launch, GridPool starts in setup-only mode and asks for a mainnet payout
address. Mining and peer services remain disabled until the address is saved.
After the address is saved, the reference node automatically restarts into
operational mode and the native SV2 service generates its configuration from
the same persisted address. Umbrel does not need to inject a custom payout
environment variable.

Install the app only after the Bitcoin app reports fully synchronized. Add
this repository URL as a Community App Store in Umbrel, then install GridPool:

```text
https://github.com/gridlabs-science/gridpool-umbrel
```

For a manual sideload, copy `gridlabs-gridpool/` into the active app-store
directory as `gridlabs-gridpool/`, then install the app ID
`gridlabs-gridpool`. App-store directory names vary between umbrelOS versions;
inspect `/home/umbrel/umbrel/app-stores/` rather than assuming a fixed suffix.

Point a native SV2 miner at:

```text
stratum2+noise://UMBREL_LAN_IP:34265
```

The GridPool dashboard also shows this endpoint under **Connect miner**. The
hostname is inferred from the browser when the package does not have a public
hostname configured, so use the Umbrel device's LAN hostname or IP if the
displayed browser hostname is not reachable from the miner.

The per-channel SV2 username may be a valid mainnet payout address. If it is a
worker label instead, the package payout address is used.

The initial appliance package disables GridPool's administrative API. It does
not provision an operator password; the dashboard hides operator-only controls
and exposes the non-sensitive miner connection and health information needed
for normal operation. Advanced operators may explicitly enable the API and set
a strong key in local configuration.

## Persistence and backup

`gridlabs-gridpool/data` contains node identity, consensus state, the local adapter
token, SV2 authority keys, and the durable proof spool. Back it up before
uninstalling or moving the app. Bitcoin chain data is owned by the separate
Bitcoin app and is not duplicated.

Before upgrading or uninstalling, stop GridPool and back up the complete data
directory with ownership and permissions preserved. Record the node-ID
fingerprint shown by the GridPool UI. Never copy Bitcoin RPC credentials from
the generated config into a support bundle.

Upgrade by replacing the app definition and recreating the app containers while
leaving `gridlabs-gridpool/data` in place. After startup, verify that the node ID,
payout address, Bitcoin authority, and SV2 authority are unchanged.

For recovery, reinstall the same or a compatible package version, stop it,
restore the saved data directory, then start the app. Deleting `pool_state.json`
is not a supported recovery procedure. A normal Umbrel uninstall may remove app
data, so retain a verified external backup first.

The legacy dashboard is disabled in the appliance package. Native SV2 is the
only supported miner-facing service; DATUM and raw SV1 remain absent.

## Current limitations

- Core IPC is intentionally not mounted across the app boundary. Standard
  `getblocktemplate`/`submitblock` RPC is used for both Core and Knots.
- DATUM and Stratum V1 adapters are not included in the initial appliance beta.

## Release verification

```bash
./scripts/verify-package.sh
```
