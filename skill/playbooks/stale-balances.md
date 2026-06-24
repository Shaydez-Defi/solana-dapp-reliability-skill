# Playbook: Stale Balances

**User report:** "I swapped/deposited but my balance didn't update."

---

## Investigation (5 minutes)

1. **Confirm on-chain state**
   - `getTokenAccountsByOwner` / `getBalance` via RPC for the user's pubkey.
   - Check Solscan/SolanaFM for the recent transaction.
   - If chain is correct but UI is wrong → state sync issue, not tx failure.

2. **Trace the UI data path**
   - Where does the balance component read from? (React Query, SWR, Zustand, direct RPC?)
   - What cache key? Is it scoped to `pubkey` + `mint`?
   - What TTL / staleTime?

3. **Trace post-transaction flow**
   - What runs on tx success? Invalidation? Optimistic update? Nothing?
   - Which commitment level triggers the update? (`processed` / `confirmed` / `finalized`)

4. **Check for indexer lag**
   - If UI reads from indexer API, compare indexer vs RPC.
   - Recent tx + indexer 404 or old value = indexer lag.

5. **Check for race**
   - Did user trigger another action before first refetch completed?
   - Are multiple components fetching with different cache keys?

---

## Fix (immediate)

| Finding | Action |
|---------|--------|
| No invalidation on tx success | Add `invalidateQueries` for `['balance', pubkey, mint]` on `confirmed` |
| Optimistic update without rollback | Reconcile from RPC within 2s; rollback on mismatch |
| Indexer lag | Fallback to RPC for 60s after any tx |
| Wrong commitment | Use `confirmed` for UI update, not `finalized` |
| Cache key missing pubkey | Namespace all wallet data by pubkey |
| Stale websocket only | Force RPC snapshot; restart subscription |

**Quick user unblock:** Add manual refresh that busts cache and refetches from RPC.

---

## Prevention

- **Pattern:** optimistic delta → confirm at `confirmed` → RPC reconcile → periodic reconciliation loop.
- **Reconciliation loop:** every 15–30s, diff critical balances against RPC for active wallet.
- **UX:** show "updating…" during reconciliation; never show stale as final without indicator.
- **Metrics:** track `balance_lag_seconds` (time from tx confirmed to UI correct).
- **Tests:** swap on mainnet → balance updates within 3s without refresh.

---

## Related Modules

- `skill/reliability/state-sync-failures.md`
- `skill/reliability/transaction-failures.md` (if tx actually failed)
- `skill/reliability/realtime-failures.md` (if websocket stopped updating)