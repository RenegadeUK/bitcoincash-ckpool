# BCH Conversion Plan

Status: planned

This plan converts the current DigiByte-based Docker stack to a Bitcoin Cash (BCH) stack incrementally, with small verifiable steps.

## 0) License and sourcing decision (must decide first)

The upstream reference repository (`skaisser/ckpool`) is GPL-3.0. This repository is currently MIT-licensed.

- If code is copied/adapted from upstream, this project should be relicensed and distributed in a GPL-compatible way.
- If upstream is only used as behavioral reference and all implementation is done independently, MIT can remain.

Decision gate:
- Choose one path before importing any upstream code.

## 1) Phase 1 — Chain baseline switch (DGB -> BCH)

Goal: switch this repo from DigiByte defaults to Bitcoin Cash defaults without adding new advanced features.

### Files to change

- `docker-compose.yaml`
- `ckpool/Dockerfile`
- `ckpool/entrypoint.sh`
- `ckpool/healthcheck.sh`
- `ckstats/Dockerfile`
- `ckstats/entrypoint.sh`

### Required edits

1. Service naming and host references:
   - `digibyte-ckpool` -> `bitcoincash-ckpool` (compose service + container references)
   - Update ckstats `API_URL` and RPC host defaults accordingly.

2. Node defaults and ports:
   - P2P: `8333`
   - RPC: `8332`
   - ZMQ: `28333`
   - Datadir default to BCH-friendly path (e.g. `/home/bitcoin/.bitcoin`).

3. Binary/tooling switch:
   - Replace DigiByte binaries/config paths with Bitcoin Cash Node equivalents (`bitcoind`, `bitcoin-cli`, `bitcoin.conf`).
   - Update startup checks in entrypoints/healthchecks to use BCH binaries.

4. Keep ckpool config minimal and safe:
   - Use single-node `btcd` block initially.
   - Preserve existing minimal fields (`btcaddress`, `btcsig`, `blockpoll`, `mindiff`, etc.).
   - Keep donation/poolfee logic unchanged in phase 1.

### Validation checklist

- `docker compose config` renders successfully.
- ckpool container starts BCH daemon and responds to `bitcoin-cli getblockchaininfo`.
- ckpool process starts and stays running.
- ckstats can reach API and run migrations.

## 2) Phase 2 — BCH configuration hardening

Goal: improve reliability and BCH behavior without changing architecture.

### Planned enhancements

- Single-node `btcd` configuration hardening for home mining.
- ZMQ notify wiring in `btcd` entries when available.
- Safer environment variable naming (`BCH_*` aliases while keeping backward compatibility).
- Stronger readiness checks (RPC alive + initial sync state).

### Validation checklist

- Single local BCH RPC endpoint stays reachable during normal operation.
- Block notifications are received with ZMQ enabled.

## 3) Phase 3 — Optional BCH feature parity from upstream

Goal: selectively adopt advanced BCH features where needed.

Potential features to evaluate:
- `lean_blocks`
- Pool fee split fields (`pooladdress`, `poolfee`) if actually needed by your operation
- Extended installer/service management scripts (if useful for non-Docker deployment)

Notes:
- Upstream docs advertise additional features; verify implementation in source before adoption.
- Avoid importing features that do not map to this Docker-first architecture.

## 4) Rollout safety rules

- Keep strong warning in README until testnet validation is complete.
- Test only on regtest/testnet first.
- Do not connect production wallets or public miners before local validation passes.

## 5) Immediate next execution step

Start Phase 1 by editing compose + entrypoints + Dockerfiles for BCH ports, binaries, and service names.