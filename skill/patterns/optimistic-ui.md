# Pattern: Optimistic UI

**Layer 3 — State Reliability**

Give users instant feedback without lying about on-chain truth.

---

## When to Use

- Swaps, deposits, transfers where waiting 2–5s for confirmation feels broken.
- Consumer DeFi where `confirmed` is sufficient for UI success.

## When NOT to Use

- High-value settlements requiring `finalized`.
- Irreversible actions where wrong success state causes real harm.

---

## Production Pattern

```
User action
  → show pending state
  → send tx
  → at processed/confirmed: apply optimistic delta
  → reconcile from RPC within 2s
  → if mismatch or tx failed: rollback + explain
```

### Rules

1. **Never** apply optimistic delta on sign intent — only after send or `confirmed`.
2. **Always** pair optimistic write with reconciliation in `finally`.
3. **Version** optimistic state; discard stale versions if newer data arrives.
4. Show "updating…" during reconciliation — not a final number.

### Rollback Triggers

- `getSignatureStatuses` returns `err`
- Confirmation timeout with no landing
- RPC reconcile value ≠ optimistic value
- User rejection (no optimistic change at all)

---

## Anti-Patterns

| Don't | Do instead |
|-------|------------|
| Optimistic on button click | Optimistic after send/confirm |
| Success UI without reconcile | 2s RPC reconcile loop |
| Rollback only on page refresh | Rollback in tx failure handler |

---

## Related

- Failures: `reliability/state-sync-failures.md`
- Playbook: `playbooks/stale-balances.md`
- Pattern: `patterns/reconciliation-patterns.md`