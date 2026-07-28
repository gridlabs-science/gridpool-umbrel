# GridPool for Umbrel

Community-app wrapper for the GridPool reference node and its canonical native
Stratum V2 server. The package uses Umbrel's installed Bitcoin implementation
through the generic RPC/ZMQ exports, so either Bitcoin Core or Bitcoin Knots can
provide the backend.

This is a sideload beta. The application UI remains behind Umbrel
authentication, the node participates outbound-only by default, and only the
SV2 miner port plus the UDP peer-relay port are published.

## Configure and install

```bash
git clone https://github.com/gridlabs-science/gridpool-umbrel.git
cd gridpool-umbrel
./configure.sh bc1qYOUR_MAINNET_PAYOUT_ADDRESS
```

Copy the `gridpool` directory into an Umbrel community app store or use
Umbrel's documented community-app sideload flow. Install the app only after the
Bitcoin app reports fully synchronized.

Point a native SV2 miner at:

```text
stratum2+noise://UMBREL_LAN_IP:34265
```

The per-channel SV2 username may be a valid mainnet payout address. If it is a
worker label instead, the package payout address is used.

## Persistence and backup

`gridpool/data` contains node identity, consensus state, the local adapter
token, SV2 authority keys, and the durable proof spool. Back it up before
uninstalling or moving the app. Bitcoin chain data is owned by the separate
Bitcoin app and is not duplicated.

## Current limitations

- Sideload configuration is a shell step; an in-app first-run payout-address
  screen remains required before submission to the official app store.
- Core IPC is intentionally not mounted across the app boundary. Standard
  `getblocktemplate`/`submitblock` RPC is used for both Core and Knots.
- DATUM and Stratum V1 adapters are not included in the initial appliance beta.
