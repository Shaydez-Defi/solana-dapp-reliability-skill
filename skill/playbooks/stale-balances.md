# Playbook: Stale Balance

**Layer 3 — State Reliability**

**Severity:** High | **Frequency:** Very Common | **User Impact:** High

---

## Symptoms

- User swapped/deposited; balance unchanged for seconds or minutes
- Refresh fixes it; user blames the app
- Explorer shows correct balance; UI does not

## Likely Causes

- No cache invalidation after tx `confirmed`
- Waiting for `finalized` before refetch
- Indexer lag behind RPC
- Optimistic update never reconciled
- Cache key missing `pubkey` or `mint`
- Websocket stopped; polling only and stale

## Verification Steps

1. RPC `getBalance` / `getTokenAccountsByOwner` — is chain correct?
2. Compare UI source: React Query? SWR? Indexer API?
3. Trace post-tx: what runs on success? Which commitment level?
4. Indexer vs RPC side-by-side if using indexer
5. Check websocket last message age if realtime-driven

## Fixes

| Finding | Action |
|---------|--------|
| No invalidation | `invalidateQueries(['balance', pubkey, mint])` on `confirmed` |
| Wrong commitment | Use `confirmed` for UI, not `finalized` |
| Indexer lag | RPC fallback for 60s after any tx |
| No reconcile | RPC poll within 2s; rollback optimistic on mismatch |
| Stale websocket | Force RPC snapshot; reconnect subscription |

**Quick unblock:** manual refresh that busts cache.

## Prevention

- Optimistic delta → confirm → RPC reconcile → periodic reconcile loop (15–30s)
- Metric: `balance_lag_seconds`
- Test: mainnet swap → UI correct within 3s without refresh

**Module:** `reliability/state-sync-failures.md`