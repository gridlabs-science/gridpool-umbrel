# GridPool Umbrel Package

This repository is a thin appliance wrapper. Consensus and runtime code belong
in `gridlabs-science/boot-protocol`; native mining code belongs in
`gridlabs-science/gridpool-sv2-pool`.

- Pin immutable runtime image tags or digests.
- Preserve `/data` across upgrades and backups.
- Never expose the GridPool UI without Umbrel authentication.
- Keep Bitcoin RPC/ZMQ private.
- Native SV2 is the only default miner transport.
- Validate both Bitcoin Core and Bitcoin Knots through Umbrel's generic
  `bitcoin` dependency exports.
