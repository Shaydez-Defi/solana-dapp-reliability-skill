# Demo Prompts

Copy-paste these to demonstrate the skill in action.

---

## Audit a codebase

```
/reliability-audit

Is my dApp ready for mainnet users?
Score all five reliability layers and run the production readiness checklist.
```

**Expected:** Agent loads `reliability-framework.md` → `production-readiness-checklist.md`

## Debug stale balance

```
User completed a swap but their USDC balance didn't update for 2 minutes.
What should I check and how do I fix it?
```

**Expected:** Agent loads `playbooks/stale-balances.md` + `reliability/state-sync-failures.md`

## Debug stuck transaction

```
Transaction spinner has been running for 5 minutes. User thinks the app is broken.
How do I diagnose and recover?
```

**Expected:** Agent loads `playbooks/tx-stuck.md` + `reliability/transaction-failures.md`

## Wallet connects but can't sign

```
Wallet shows connected but every transaction fails at signing. Phantom on desktop.
```

**Expected:** Agent loads `playbooks/wallet-cannot-sign.md` + `reliability/wallet-failures.md`

## RPC outage

```
All RPC calls returning 429. App is completely down for users.
What's the immediate fallback procedure?
```

**Expected:** Agent loads `playbooks/rpc-outage.md` + `reliability/rpc-failures.md`

## Websocket silence

```
Live prices stopped updating 10 minutes ago. No error in the UI.
```

**Expected:** Agent loads `playbooks/websocket-failure.md` + `reliability/realtime-failures.md`

## Kit migration

```
We use web3.js with wallet-adapter across 40 files.
What's the safest phased migration to @solana/kit without breaking production?
```

**Expected:** Agent loads `migration/kit-migration.md`

## Transaction flow review

```
Trace our swap flow from button click to UI update.
Find every place it can fail silently.
```

**Expected:** Agent loads `reliability-framework.md` (Layer 2) → `playbooks/tx-stuck.md` → `reliability/transaction-failures.md`