# Pattern: Reconciliation

**Layer 3 — State Reliability**

Keep UI state aligned with on-chain truth — continuously, not only on page load.

---

## The Problem Reconciliation Solves

Caches, indexers, websockets, and optimistic UI all drift. Reconciliation is the **correction loop** that fixes drift before users notice.

---

## Three Reconciliation Strategies

### 1. Event-Driven (post-transaction)

On tx `confirmed`:
- Invalidate wallet-scoped queries
- RPC-fetch affected accounts immediately
- Compare to UI; correct if different

**Best for:** balance updates after swaps/deposits.

### 2. Periodic (background loop)

Every 15–30s for active wallet:
- RPC-fetch critical balances (SOL, primary tokens)
- Diff against UI state
- Correct silently or show "synced" indicator

**Best for:** long sessions, missed websocket events.

### 3. Hybrid (indexer + RPC)

- Indexer for history and portfolio lists
- RPC for anything that changed in last 60s
- If indexer 404 after recent tx → RPC fallback with backoff

**Best for:** apps using Helius/Triton/custom indexers.

---

## Implementation Checklist

- [ ] Reconciliation keyed by `pubkey` + `mint` / account
- [ ] Slot or version guard — ignore stale updates
- [ ] Metric: `balance_lag_seconds` from tx confirm → UI correct
- [ ] Alert if p95 lag > 3s

---

## Related

- Failures: `reliability/state-sync-failures.md`
- Pattern: `patterns/optimistic-ui.md`
- Pattern: `patterns/hybrid-subscriptions.md`