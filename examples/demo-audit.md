# Demo Audit: Solana Foundation Counter Template

**Target:** [solana-foundation/templates — web3js-react-vite-tailwind-counter](https://github.com/solana-foundation/templates/tree/main/web3js/web3js-react-vite-tailwind-counter)

**Command run:** `/reliability-audit`

**Framework applied:** The Reliability Framework (5 layers) + Production Readiness Checklist

**Why this target:** Official Solana starter template — widely forked by hackathon teams. Auditing it shows how the framework catches gaps that pass devnet QA but fail in production.

---

## Reliability Score: web3js-react-vite-tailwind-counter

| Layer | Score | Top Issue |
|-------|-------|-----------|
| 1 — Wallet Reliability | 62/100 | Empty `wallets={[]}` — no adapters registered |
| 2 — Transaction Reliability | 58/100 | No simulation; errors swallowed silently |
| 3 — State Reliability | 71/100 | Refetch-on-success only; no reconciliation pattern |
| 4 — Realtime Reliability | 35/100 | Zero websocket subscriptions |
| 5 — Infrastructure Reliability | 48/100 | Single public RPC; no failover |
| **Overall** | **55/100** | **Fragile — not mainnet-ready** |

## Mainnet Readiness Checklist

**18/35 items passed (51%)**  
**Verdict:** Not ready for mainnet users at scale. OK for devnet/hackathon prototype only.

### Blockers
- [ ] Wallet adapters registered
- [ ] `simulateTransaction` before sign
- [ ] RPC failover configured
- [ ] Websocket reconnect strategy
- [ ] Optimistic updates reconciled (N/A yet — but no reconciliation loop either)

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
**Playbook:** `playbooks/wallet-reconnect.md`

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
**Pattern:** `patterns/transaction-recovery.md`

---

### Layer 2 — No simulation before send

**Severity:** High | **Frequency:** Very Common (mainnet) | **User Impact:** High

Flow: build → `sendTransaction` → `confirmTransaction`. No `simulateTransaction`.

**Pattern:** `patterns/transaction-recovery.md` (pre-flight simulation)

---

### Layer 5 — Single public RPC

**Severity:** High | **Frequency:** Common | **User Impact:** High

Default: `clusterApiUrl('devnet')`. No secondary provider, health check, or failover.

**Pattern:** `patterns/rpc-failover.md`  
**Playbook:** `playbooks/rpc-outage.md`

---

### Layer 4 — No realtime data layer

**Severity:** High | **Frequency:** Very Common | **User Impact:** High

React Query polling only. No websocket, heartbeat, or hybrid reconcile.

**Pattern:** `patterns/hybrid-subscriptions.md`  
**Module:** `reliability/realtime-failures.md`

---

### Layer 3 — No reconciliation after tx

**Severity:** High | **Frequency:** Very Common | **User Impact:** High

Refetch on success only. No optimistic UI rollback, no periodic reconcile loop.

**Pattern:** `patterns/reconciliation-patterns.md`

---

## What's Working Well

- Cache keys include endpoint + address
- Blockhash fetched before tx build
- Confirmation at `confirmed` (not over-waiting for `finalized`)
- Counter mutations refetch after success
- Transaction toast with explorer link (counter flows only)

---

## Recommendations (ranked by user impact)

1. Register wallet adapters (Layer 1)
2. Fix `useTransferSol` error handling (Layer 2) → `patterns/transaction-recovery.md`
3. Add simulation pre-flight (Layer 2)
4. Add reconciliation loop (Layer 3) → `patterns/reconciliation-patterns.md`
5. Hybrid subscriptions for counter account (Layer 4) → `patterns/hybrid-subscriptions.md`
6. Dual RPC providers (Layer 5) → `patterns/rpc-failover.md`

---

## Prompt That Triggered This Audit

```
/reliability-audit

Is this dApp ready for mainnet users?
Score all five reliability layers and run the production readiness checklist.
```

**Skill modules loaded:**
`framework/reliability-framework.md` → `commands/reliability-audit.md` → `audits/reliability-score.md` → `audits/production-readiness-checklist.md` → `reliability/wallet-failures.md` → `reliability/transaction-failures.md`

**Progressive loading verified:** Framework + audit + 2 layer modules — not all 30+ files.