# Pattern: Transaction Recovery

**Layer 2 — Transaction Reliability**

Transactions fail, drop, expire, and confuse users. Production apps recover gracefully.

---

## Transaction State Machine

Every tx UI must implement explicit states:

```
idle → awaiting_signature → sending → confirming → confirmed
                                              ↘ failed
                                              ↘ rejected
                                              ↘ dropped (timeout, not found)
                                              ↘ expired (blockhash)
```

Never use a single "loading" spinner for all of these.

---

## Recovery by Scenario

### Expired blockhash
1. Fetch fresh blockhash
2. Rebuild tx with same intent
3. Ask user to re-sign only if contents changed
4. Show: "Transaction expired — please try again"

### User rejection
1. Message: "Cancelled — no funds were moved"
2. Preserve form input
3. Do **not** rollback optimistic state that was never applied

### Simulation failure
1. Never open wallet popup
2. Map program logs to human message
3. Offer fix: add SOL, create ATA, reduce amount

### Dropped (not found after 90s)
1. `getSignatureStatuses` returns null
2. Show explorer link + "May have been dropped"
3. Offer retry with fresh blockhash — not duplicate sign blindly

### Confirmed but UI stuck
1. Force update from `getSignatureStatuses`
2. Fix listener bug separately
3. Invalidate dependent caches

---

## Timeout Policy

| Elapsed | UI behavior |
|---------|-------------|
| 0–30s | "Confirming…" + explorer link |
| 30–90s | "Network busy — still confirming" |
| 90s+ | "Not confirmed yet — check explorer or retry" |
| 5min+ | Suggest retry; do not show false failure |

---

## Idempotency Rules

- Disable submit from first click until terminal state
- Resubmitting **same signed bytes** is safe
- Asking user to **sign again** is not — use idempotency keys
- Log: signature, send time, confirm time, provider, commitment level

---

## Related

- Failures: `reliability/transaction-failures.md`
- Playbook: `playbooks/tx-stuck.md`
- Pattern: `patterns/optimistic-ui.md` (rollback on failure)