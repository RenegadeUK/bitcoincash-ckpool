# bitcoincash-ckpool

⚠️ WARNING: UNDER DEVELOPMENT — DO NOT USE FOR PRODUCTION OR REAL MINING.

This repository is currently being converted from DigiByte (DGB) ckpool setup to Bitcoin Cash (BCH).
It is incomplete and may contain incorrect chain, RPC, payout, wallet, and pool settings.

Use at your own risk.

This project currently contains a recovered DGB-oriented baseline plus BCH migration work.

Scope: single-node only (home miner setup). Multi-node failover is intentionally out of scope.

## Migration Plan

See `docs/BCH_CONVERSION_PLAN.md` for the phased conversion plan and implementation checklist.

## Quick Start (Local)

1. Create your runtime config:
	 - `cp .env.example .env`
	 - Edit `.env` and set at least `BTCADDRESS`, `RPCUSER`, and `RPCPASSWORD`.
2. Build and start:
	 - `docker compose up --build`
3. Optional clean reset (fresh DB/data test):
	 - `docker compose down -v --remove-orphans`

## Validation Checks

- Service status:
	- `docker compose ps`
- BCH node RPC + pruning:
	- `docker exec bitcoincash-ckpool bitcoin-cli -conf=/etc/bitcoin/bitcoin.conf getblockchaininfo`
	- Expected fields include `"pruned": true` and `"automatic_pruning": true`
- ckstats UI:
	- Open `http://localhost:3000`

## Upstream Reference

The repository `https://github.com/skaisser/ckpool` has been added as the `upstream` remote for BCH reference and diffing.
