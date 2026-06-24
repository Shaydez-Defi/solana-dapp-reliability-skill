# Demo Prompts

Copy-paste these to demonstrate the skill in action.

---

## Audit a codebase

```
/reliability-audit

Is my dApp ready for mainnet users?
Score all five reliability layers and run the production readiness checklist.
```

## Debug stale balance

```
User completed a swap but their USDC balance didn't update for 2 minutes.
What should I check and how do I fix it?
```

**Expected:** Agent loads `reliability/state-sync-failures.md` + `playbooks/stale-balances.md`

## Debug stuck transaction

```
Transaction spinner has been running for 5 minutes. User thinks the app is broken.
How do I diagnose and recover?
```

**Expected:** Agent loads `playbooks/tx-stuck.md` + `reliability/transaction-failures.md`

## Wallet reconnect loop

```
Phantom connects then immediately disconnects in a loop. Only happens on mobile Safari.
```

**Expected:** Agent loads `reliability/wallet-failures.md` + `playbooks/wallet-reconnect.md`

## RPC outage

```
All RPC calls returning 429. App is completely down for users.
What's the immediate fallback procedure?
```

**Expected:** Agent loads `playbooks/rpc-outage.md` + `reliability/rpc-failures.md`

## Kit migration

```
/migrate-to-kit

We use web3.js with wallet-adapter across 40 files.
What's the safest phased migration to @solana/kit?
```

**Expected:** Agent loads `commands/migrate-to-kit.md` + `migration/kit-migration.md`

## Transaction flow review

```
/tx-flow-audit

Trace our swap flow from button click to UI update.
Find every place it can fail silently.
```

**Expected:** Agent loads `commands/tx-flow-audit.md` + transaction modules