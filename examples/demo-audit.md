# Demo Audit: Solana Foundation Counter Template

**Target:** [solana-foundation/templates — web3js-react-vite-tailwind-counter](https://github.com/solana-foundation/templates/tree/main/web3js/web3js-react-vite-tailwind-counter)

**Trigger:** `/reliability-audit` or "Is this dApp ready for mainnet users?"

**Framework applied:** The DApp Reliability Framework (5 layers) + Reliability Score + Production Readiness Checklist (10 items)

**Why this target:** Official Solana starter template — widely forked by hackathon teams. Auditing it shows how the framework catches gaps that pass devnet QA but fail in production.

---

## Mainnet Readiness: web3js-react-vite-tailwind-counter

```
Wallet Reliability:          62
Transaction Reliability:     58
State Reliability:           71
Realtime Reliability:        35
Infrastructure Reliability:  48
────────────────────────────────
Overall Score:               55

Checklist: 2/10 passed
Verdict: Not mainnet-ready — OK for devnet/hackathon prototype only.
```

| Layer | Top Issue |
|-------|-----------|
| 1 — Wallet | Empty `wallets={[]}` — no adapters registered |
| 2 — Transaction | No simulation; errors swallowed silently |
| 3 — State | Refetch-on-success only; no reconciliation |
| 4 — Realtime | Zero websocket subscriptions |
| 5 — Infrastructure | Single public RPC; no failover |

### Checklist Results

| Item | Status |
|------|--------|
| Wallet recovery tested | ❌ No adapters to test |
| Mobile wallet tested | ❌ |
| RPC failover configured | ❌ Single devnet RPC |
| WebSocket recovery configured | ❌ No subscriptions |
| Optimistic updates reconciled | ⚠️ N/A — no optimistic UI |
| Retry logic exists | ❌ |
| Rate limits handled | ❌ Public RPC only |
| Transaction failure UX exists | ❌ Errors swallowed |
| Indexer lag handled | ❌ |
| State reconciliation implemented | ❌ Refetch-on-success only |

### Blockers (fix first)

1. Register wallet adapters (Layer 1) → `playbooks/wallet-cannot-sign.md`
2. Fix silent tx error handling (Layer 2) → `playbooks/tx-stuck.md`
3. Add RPC failover (Layer 5) → `playbooks/rpc-outage.md`

---

## Critical Findings

### Layer 1 — Empty wallet adapter list

**Severity:** Critical | **Frequency:** Always (stock template) | **User Impact:** Critical

**File:** `src/components/solana/solana-provider.tsx`

```tsx
<WalletProvider wallets={[]} onError={onError} autoConnect={true}>
```

No wallet adapters registered. Users cannot connect in a stock clone.

**Fix:** Register `PhantomWalletAdapter`, `SolflareWalletAdapter`, etc.  
**Playbook:** `playbooks/wallet-cannot-sign.md`

---

### Layer 2 — Transaction errors swallowed

**Severity:** Critical | **Frequency:** Common | **User Impact:** High

**File:** `src/components/account/account-data-access.tsx`

```tsx
} catch (error: unknown) {
  console.log('error', `Transaction failed! ${error}`, signature)
  return  // mutation appears to "succeed"
}
```

`onSuccess` still invalidates queries — UI may refresh as if tx worked.

**Fix:** Re-throw or use `onError`. Never invalidate on failed sends.  
**Playbook:** `playbooks/tx-stuck.md`

---

### Layer 2 — No simulation before send

**Severity:** High | **Frequency:** Very Common (mainnet) | **User Impact:** High

Flow: build → `sendTransaction` → `confirmTransaction`. No `simulateTransaction`.

**Playbook:** `playbooks/tx-stuck.md` (pre-flight simulation step)

---

### Layer 5 — Single public RPC

**Severity:** High | **Frequency:** Common | **User Impact:** High

Default: `clusterApiUrl('devnet')`. No secondary provider, health check, or failover.

**Playbook:** `playbooks/rpc-outage.md`

---

### Layer 4 — No realtime data layer

**Severity:** High | **Frequency:** Very Common | **User Impact:** High

React Query polling only. No websocket, heartbeat, or hybrid reconcile.

**Playbook:** `playbooks/websocket-failure.md`  
**Module:** `reliability/realtime-failures.md`

---

### Layer 3 — No reconciliation after tx

**Severity:** High | **Frequency:** Very Common | **User Impact:** High

Refetch on success only. No optimistic UI rollback, no periodic reconcile loop.

**Playbook:** `playbooks/stale-balances.md`

---

## What's Working Well

- Cache keys include endpoint + address
- Blockhash fetched before tx build
- Confirmation at `confirmed` (not over-waiting for `finalized`)
- Counter mutations refetch after success
- Transaction toast with explorer link (counter flows only)

---

## Recommendations (ranked by user impact)

1. Register wallet adapters (Layer 1) → `playbooks/wallet-cannot-sign.md`
2. Fix `useTransferSol` error handling (Layer 2) → `playbooks/tx-stuck.md`
3. Add simulation pre-flight (Layer 2) → `reliability/transaction-failures.md`
4. Add reconciliation loop (Layer 3) → `playbooks/stale-balances.md`
5. Hybrid subscriptions for counter account (Layer 4) → `playbooks/websocket-failure.md`
6. Dual RPC providers (Layer 5) → `playbooks/rpc-outage.md`

---

## Prompt That Triggered This Audit

```
/reliability-audit

Is this dApp ready for mainnet users?
Score all five reliability layers and run the production readiness checklist.
```

**Skill modules loaded:**
`reliability-framework.md` → `production-readiness-checklist.md` → `reliability-score.md`

**Progressive loading verified:** Framework + checklist + score rubric — 3 files, not the full skill dump.