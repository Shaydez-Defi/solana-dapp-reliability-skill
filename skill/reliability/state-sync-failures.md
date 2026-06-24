# State Sync Failures

Why UI state drifts from on-chain truth — the most common production complaint.

---

## Problem: Stale Balances After Transaction

**Severity:** High — #1 user complaint after swaps and deposits.

### Symptoms
- User completes swap/deposit; balance unchanged for seconds or minutes.
- Refresh fixes it; users blame the app.
- Token balance correct but SOL balance stale (or vice versa).

### Likely Causes
- UI waiting for finalized confirmation before refetch.
- Cache TTL too long; no invalidation on tx success.
- Indexer lag (Helius, Triton, custom) behind RPC.
- Optimistic update applied but never reconciled.

### Diagnosis
1. Trace post-tx flow: what triggers refetch? Which commitment level?
2. Compare RPC `getTokenAccountsByOwner` vs indexer API vs UI display.
3. Measure lag: time from confirmation to correct UI.
4. Check if only one asset type refetches (SOL vs SPL).

### Fix
- On tx `confirmed`: invalidate wallet-scoped queries immediately.
- Apply optimistic delta, then reconcile within 2s via RPC poll.
- Show "updating balance…" rather than stale number.
- Fallback: manual refresh button always available.

### Prevention
- Reconciliation loop: every 10–30s, diff UI vs RPC for active wallet.
- See `playbooks/stale-balances.md`.

---

## Problem: Optimistic Update Never Reconciled

**Severity:** Critical — UI shows success when tx failed; ghost balances.

### Symptoms
- UI shows success state; on-chain tx actually failed.
- Balance inflated until page refresh.
- "Ghost" positions appear after failed transactions.

### Likely Causes
- Optimistic update applied on sign, not on confirmation.
- No rollback on tx failure or timeout.
- Reconciliation only on full page load.

### Diagnosis
1. Find where optimistic state is written — before or after `sendRawTransaction`?
2. Confirm failure/timeout handlers revert optimistic state.
3. Test: reject tx, expire blockhash, simulate failure — does UI recover?

### Fix
- Apply optimistic update on `processed` or `confirmed`, not on sign intent.
- Always pair optimistic write with `finally` reconciliation.
- Use version numbers on state; discard stale optimistic versions.

### Prevention
- Pattern: `optimistic → confirm → reconcile → rollback if mismatch`.
- Log optimistic/reconciled pairs for debugging.
- Never show "completed" until at least `confirmed` unless product explicitly accepts risk.

---

## Problem: Race Conditions on Rapid Actions

**Severity:** High — wrong balances and failed txs on rapid clicks.

### Symptoms
- Two quick clicks produce wrong final balance.
- Second tx uses stale account data from before first landed.
- Intermittent "account not found" or insufficient funds.

### Likely Causes
- Parallel txs without sequencing.
- Shared mutable state in tx builder.
- Refetch from tx1 not complete before tx2 builds.

### Diagnosis
1. Reproduce with rapid double-submit.
2. Check if account data is fetched per-tx or cached globally.
3. Look for missing mutex/queue on wallet operations.

### Fix
- Serialize wallet operations per user session (queue).
- Fetch fresh accounts inside each tx build, not from shared cache.
- Disable concurrent actions while one is in-flight.

### Prevention
- Tx queue with visible "1 transaction ahead of you" indicator.
- Idempotency keys per user action.
- Integration tests for rapid sequential actions.

---

## Problem: Cache Inconsistency Across Components

**Severity:** Medium — confusing UX; different pages show different numbers.

### Symptoms
- Header shows balance X; portfolio page shows Y.
- NFT count differs between gallery and profile.
- Works after hard refresh only.

### Likely Causes
- Multiple data libraries (SWR + React Query + local state).
- Different cache keys for same data.
- One component polls; another uses stale initial fetch.

### Diagnosis
1. Inventory all data fetching for one entity (e.g. USDC balance).
2. Compare cache keys, TTL, and invalidation triggers.
3. Check for duplicate RPC calls with different parameters.

### Fix
- Single source of truth per entity type.
- Unified cache key scheme: `['tokenBalance', mint, owner]`.
- Broadcast invalidation on tx events to all consumers.

### Prevention
- Architecture rule: one data layer per domain (wallet, positions, NFTs).
- Lint or codemod against direct RPC calls in leaf components.
- Document cache key conventions in `AGENTS.md` or team wiki.

---

## Problem: Delayed Indexing

**Severity:** High — correct on-chain, wrong in app for 30–60s after tx.

### Symptoms
- RPC shows correct state; app via indexer does not.
- New token accounts missing for 30–60s.
- Historical data correct; realtime wrong.

### Likely Causes
- Indexer ingestion lag during high volume.
- App reads indexer for display, RPC for tx — two truths.
- No fallback when indexer returns 404 for new accounts.

### Diagnosis
1. Hit RPC and indexer APIs side-by-side after known tx.
2. Measure indexer lag under load.
3. Identify which reads go to indexer vs RPC.

### Fix
- Hybrid read: indexer for history, RPC for post-tx immediate reads.
- Retry with backoff when indexer returns empty after recent tx.
- Show data source and freshness timestamp in debug mode.

### Prevention
- SLA-aware routing: if indexer stale > N seconds, fall back to RPC.
- Monitor indexer lag metric; alert before users notice.
- Never treat indexer as sole source for balances that just changed.

---

## Problem: Account Update Ordering

**Severity:** Medium — UI flicker; usually self-corrects on refresh.

### Symptoms
- Events arrive out of order; UI flickers.
- Older balance overwrites newer.
- Subscription replay shows duplicate then missing updates.

### Likely Causes
- Websocket events processed without sequence awareness.
- Multiple subscriptions to same account without dedup.
- Async handlers complete in random order.

### Diagnosis
1. Log event slot and write version for each account update.
2. Check for multiple `onAccountChange` listeners on same pubkey.
3. Reproduce under websocket reconnect.

### Fix
- Ignore updates with slot < last applied slot.
- Debounce rapid updates; apply only latest per account per tick.
- Single subscription manager per account.

### Prevention
- Centralized subscription registry with reference counting.
- See `reliability/realtime-failures.md` for transport details.
- Reconcile from RPC after reconnect before trusting stream.