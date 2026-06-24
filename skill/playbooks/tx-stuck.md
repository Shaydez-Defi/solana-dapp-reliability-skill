# Playbook: Transaction Stuck

**Layer 2 — Transaction Reliability**

**Severity:** High | **Frequency:** Common | **User Impact:** High

---

## Symptoms

- Spinner never stops; user thinks funds are lost
- No explorer link; no timeout message
- "Pending" forever though tx may have confirmed or failed

## Likely Causes

- Waiting for `finalized` when `confirmed` is enough
- Websocket confirmation listener died; no polling fallback
- No timeout policy
- Expired blockhash — tx never landed
- `getSignatureStatuses` never called

## Verification Steps

1. Get signature from logs/wallet — or confirm tx never sent
2. `getSignatureStatuses([sig])` — null / err / confirmed?
3. Check explorer: landed, failed, or not found after 2min?
4. Map all confirmation call sites — mixed commitment levels?
5. Check if UI success triggers before `confirmed`

## Fixes

| Status | Action |
|--------|--------|
| Failed on-chain | Show failure + explorer link; rollback optimistic state |
| Confirmed | Force status update; fix listener bug; invalidate caches |
| Not found (90s+) | "May have been dropped" + explorer + retry option |
| Congested | Honest wait message + backoff poll + priority fee on retry |

## Prevention

- Timeout: 90s → "still confirming" + explorer; 5min → suggest retry
- UI success at `confirmed`; single tx status service for all components
- Log: signature, send time, confirm time, provider, commitment

**Module:** `reliability/transaction-failures.md`