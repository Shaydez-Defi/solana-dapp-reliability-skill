# Demo Audit: Solana Foundation Counter Template

**Target:** [solana-foundation/templates — web3js-react-vite-tailwind-counter](https://github.com/solana-foundation/templates/tree/main/web3js/web3js-react-vite-tailwind-counter)

**Command run:** `/reliability-audit`

**Why this target:** Official Solana starter template — widely forked by hackathon teams. Auditing it shows how the skill catches gaps that pass devnet QA but fail in production.

---

## Reliability Audit: web3js-react-vite-tailwind-counter

| Category | Score | Top Issue |
|----------|-------|-----------|
| Wallet Reliability | 62/100 | Empty `wallets={[]}` — no adapters registered |
| Transaction Reliability | 58/100 | No simulation; errors swallowed silently |
| State Consistency | 71/100 | Refetch-on-success only; no realtime sync |
| Realtime Reliability | 35/100 | Zero websocket subscriptions |
| RPC Reliability | 48/100 | Single public RPC; no failover |
| Failure Recovery | 40/100 | User-facing toasts disabled; console-only errors |
| **Overall** | **52/100** | **Not production-ready** |

---

## Critical Findings

### 1. Empty wallet adapter list (Wallet — Critical)

**File:** `src/components/solana/solana-provider.tsx`

```tsx
<WalletProvider wallets={[]} onError={onError} autoConnect={true}>
```

No wallet adapters are registered. `autoConnect` runs against an empty list. Users cannot connect Phantom, Backpack, or WalletConnect in a stock clone without adding adapters manually.

**Fix:** Register `PhantomWalletAdapter`, `SolflareWalletAdapter`, etc. Test connect on desktop and mobile.

**Playbook:** `skill/playbooks/wallet-reconnect.md`

---

### 2. Transaction errors swallowed (Transaction — Critical)

**File:** `src/components/account/account-data-access.tsx`

```tsx
} catch (error: unknown) {
  console.log('error', `Transaction failed! ${error}`, signature)
  return  // returns undefined — mutation appears to "succeed"
}
```

Failures are logged to console and return `undefined`. `onSuccess` still runs and invalidates queries — UI may refresh as if the tx worked.

**Fix:** Re-throw or use `onError`. Distinguish user rejection from network failure. Never invalidate state on failed sends.

**Module:** `skill/reliability/transaction-failures.md`

---

### 3. No simulation before send (Transaction — High)

**File:** `src/components/account/account-data-access.tsx` — `useTransferSol`

Flow: build tx → `wallet.sendTransaction` → `confirmTransaction`. No `simulateTransaction` step.

On mainnet, users sign txs that will fail (insufficient SOL, bad account) with cryptic wallet errors.

**Fix:** Simulate before wallet prompt. Map program logs to user-readable errors.

---

### 4. Single public RPC endpoint (RPC — High)

**File:** `src/components/cluster/cluster-data-access.tsx`

```tsx
endpoint: clusterApiUrl('devnet')
```

Default is public devnet RPC. README notes mainnet public endpoint has CORS restrictions — but even with a custom mainnet URL, there is no secondary provider, health check, or failover.

**Fix:** Primary + secondary RPC with health-aware routing. Never ship public `api.mainnet-beta.solana.com` to production.

**Playbook:** `skill/playbooks/rpc-outage.md`

---

### 5. No realtime data layer (Realtime — High)

Balances and counter state use React Query polling only. No `onAccountChange`, no websocket heartbeat, no hybrid reconcile loop.

After a tx, UI waits for `refetch()` — users see stale counter values until refetch completes. Silent RPC slowdown = frozen UI with no degraded-state banner.

**Fix:** Subscribe to counter account via websocket. Add periodic RPC reconciliation. Show "updating…" during lag.

**Module:** `skill/reliability/realtime-failures.md`

---

### 6. User feedback disabled (Failure Recovery — High)

**File:** `src/components/account/account-data-access.tsx`

```tsx
// const transactionToast = useTransactionToast()
// TODO: Add back Toast
```

Transfer and airdrop flows have toast notifications commented out. Counter mutations use toasts, but account flows do not — inconsistent UX. Users get no feedback on success or failure for SOL transfers.

**Fix:** Enable toasts on all tx paths. Add explorer links. Show distinct messages for rejection vs failure vs timeout.

---

## What's Working Well

- **Cache keys include endpoint + address** — cluster switch won't serve wrong-network data.
- **Blockhash fetched before tx build** — `createTransaction` gets fresh blockhash.
- **Confirmation at `confirmed`** — not over-waiting for `finalized`.
- **Counter mutations refetch after success** — basic post-tx invalidation pattern exists.
- **Transaction toast with explorer link** — good pattern in `use-transaction-toast.tsx` (used by counter, not account).

---

## Recommendations (ranked by user impact)

1. **Register wallet adapters** — without this, nothing else matters.
2. **Fix error handling in `useTransferSol`** — stop treating failures as success.
3. **Add simulation pre-flight** — reduce failed signatures on mainnet.
4. **Enable user-facing tx toasts on all flows** — consistent success/failure/rejection messaging.
5. **Add websocket subscription for counter account** — eliminate stale UI after increment/decrement.
6. **Configure dual RPC providers** — survive rate limits and outages.

---

## Quick Wins (< 1 day)

- Uncomment `useTransactionToast` in account mutations.
- Add Phantom + Solflare to `wallets` array.
- Change `useTransferSol` catch block to `throw error`.
- Add `isPending` disable on all submit buttons (verify counter UI).

## Strategic Improvements (> 1 week)

- Central tx pipeline: simulate → sign → send → confirm → invalidate.
- Hybrid realtime: websocket + 15s RPC reconciliation.
- Multi-RPC router with health checks.
- Optimistic counter updates with rollback on failure.

---

## Prompt That Triggered This Audit

```
/reliability-audit

Review this Solana counter dApp template for production reliability.
Focus on wallet setup, transaction flow, state sync, and RPC config.
```

**Skill modules loaded:** `rules/reliability-rules.md` → `commands/reliability-audit.md` → `skill/audits/reliability-checklist.md` → `skill/reliability/wallet-failures.md` → `skill/reliability/transaction-failures.md` → `skill/reliability/state-sync-failures.md`

**Progressive loading verified:** Agent did not load all 21 files — only router + audit command + relevant modules.