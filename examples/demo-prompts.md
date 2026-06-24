# Demo Prompts

Copy-paste these to demonstrate the skill in action.

---

## Audit a codebase

```
/reliability-audit

Review my Solana dApp for production reliability before mainnet launch.
Score wallet, transaction, state sync, realtime, RPC, and failure recovery.
```

## Debug stale balance

```
User completed a swap but their USDC balance didn't update for 2 minutes.
What should I check and how do I fix it?
```

**Expected:** Agent loads `skill/reliability/state-sync-failures.md` + `skill/playbooks/stale-balances.md`

## Debug stuck transaction

```
Transaction spinner has been running for 5 minutes. User thinks the app is broken.
How do I diagnose and recover?
```

**Expected:** Agent loads `skill/playbooks/tx-stuck.md` + `skill/reliability/transaction-failures.md`

## Wallet reconnect loop

```
Phantom connects then immediately disconnects in a loop. Only happens on mobile Safari.
```

**Expected:** Agent loads `skill/reliability/wallet-failures.md` + `skill/playbooks/wallet-reconnect.md`

## RPC outage

```
All RPC calls returning 429. App is completely down for users.
What's the immediate fallback procedure?
```

**Expected:** Agent loads `skill/playbooks/rpc-outage.md` + `skill/reliability/rpc-failures.md`

## Kit migration

```
/migrate-to-kit

We use web3.js with wallet-adapter across 40 files.
What's the safest phased migration to @solana/kit?
```

**Expected:** Agent loads `commands/migrate-to-kit.md` + `skill/migration/kit-migration.md`

## Transaction flow review

```
/tx-flow-audit

Trace our swap flow from button click to UI update.
Find every place it can fail silently.
```

**Expected:** Agent loads `commands/tx-flow-audit.md` + transaction modules