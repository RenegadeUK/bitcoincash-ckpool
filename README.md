# bitcoincash-ckpool

⚠️ WARNING: UNDER DEVELOPMENT — DO NOT USE FOR PRODUCTION OR REAL MINING.

This repository is currently being converted from DigiByte (DGB) ckpool setup to Bitcoin Cash (BCH).
It is incomplete and may contain incorrect chain, RPC, payout, wallet, and pool settings.

Use at your own risk.

This project currently contains a recovered DGB-oriented baseline plus BCH migration work.

Scope: single-node only (home miner setup). Multi-node failover is intentionally out of scope.

Container images are not built/published by GitHub Actions in this repository.
Use source code from this repo and build locally with Docker Compose.

Default host ports are intentionally offset to avoid clashing with your DigiByte stack:
- BCH P2P: `18333`
- BCH RPC: `18332`
- Stratum: `4333`
- ckpool API: `14028`
- Logs HTTP: `13001`
- ckstats UI: `13000`
- PostgreSQL: `15432`

## Migration Plan

See `docs/BCH_CONVERSION_PLAN.md` for the phased conversion plan and implementation checklist.

## Quick Start (Local)

1. Clone and enter the repo:
	 - `git clone https://github.com/RenegadeUK/bitcoincash-ckpool.git`
	 - `cd bitcoincash-ckpool`
2. Create your runtime config:
	 - `cp .env.example .env`
	 - Edit `.env` and set at least `BTCADDRESS`, `RPCUSER`, and `RPCPASSWORD`.
3. Build and start:
	 - `docker compose up --build`
4. Optional clean reset (fresh DB/data test):
	 - `docker compose down -v --remove-orphans`

## Validation Checks

- Service status:
	- `docker compose ps`
- BCH node RPC + pruning:
	- `docker exec bitcoincash-ckpool bitcoin-cli -conf=/etc/bitcoin/bitcoin.conf getblockchaininfo`
	- Expected fields include `"pruned": true` and `"automatic_pruning": true`
- ckstats UI:
	- Open `http://localhost:13000`

### Initial Sync Note

On first run, BCH node sync can take significant time. While `initialblockdownload=true`, pool stats/API output may be incomplete and the dashboard can show limited/no stats.

## Sync & Connections Monitoring

- Sync status (one-shot):
	- `docker exec bitcoincash-ckpool bitcoin-cli -conf=/etc/bitcoin/bitcoin.conf getblockchaininfo`
- Key sync fields to watch:
	- `blocks`
	- `headers`
	- `verificationprogress`
	- `initialblockdownload`
- Current connection count:
	- `docker exec bitcoincash-ckpool bitcoin-cli -conf=/etc/bitcoin/bitcoin.conf getnetworkinfo | jq '.connections'`
- Peer count:
	- `docker exec bitcoincash-ckpool bitcoin-cli -conf=/etc/bitcoin/bitcoin.conf getpeerinfo | jq 'length'`
- Peer addresses:
	- `docker exec bitcoincash-ckpool bitcoin-cli -conf=/etc/bitcoin/bitcoin.conf getpeerinfo | jq '.[].addr'`
- Live watch every 10 seconds:
	- `watch -n 10 "docker exec bitcoincash-ckpool bitcoin-cli -conf=/etc/bitcoin/bitcoin.conf getblockchaininfo | jq '{blocks,headers,verificationprogress,initialblockdownload}'"`

## Upstream Reference

The repository `https://github.com/skaisser/ckpool` has been added as the `upstream` remote for BCH reference and diffing.
