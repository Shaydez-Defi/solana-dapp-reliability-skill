# Playbook: Websocket Failure

**User report:** "Data stopped updating" / "App feels frozen but no error."

---

## Investigation

1. **Check connection liveness**
   - When was the last websocket message received?
   - Is `readyState === OPEN`?
   - Any `onerror` / `onclose` events in logs?

2. **Check subscription health**
   - How many active subscriptions? (Should match watched accounts, not grow unbounded.)
   - Duplicate subscriptions after reconnect?

3. **Compare websocket vs RPC**
   - Fetch same account via HTTP RPC.
   - If RPC is fresh but websocket stale → transport issue, not chain issue.

4. **Environmental factors**
   - Laptop sleep, mobile background, VPN, ad blocker.
   - Provider websocket limits or maintenance.

---

## Recovery

1. **Immediate:** force reconnect websocket; resubscribe all accounts.
2. **Snapshot:** RPC-fetch all critical accounts before trusting stream again.
3. **Notify user:** "Reconnecting to live data…" — not silent recovery.
4. **Fallback:** if reconnect fails 3×, switch to polling mode (15–30s interval).
5. **Cleanup:** remove duplicate listeners before resubscribing.

---

## Monitoring

Track these metrics:
- `ws_last_message_age_seconds`
- `ws_reconnect_count_per_session`
- `ws_subscription_count`
- `data_staleness_seconds` (UI value vs RPC truth)

Alert when `ws_last_message_age_seconds > 60` during active session.

---

## Fallback Strategies

| Priority | Strategy |
|----------|----------|
| 1 | Reconnect with exponential backoff + jitter |
| 2 | Full RPC snapshot on reconnect |
| 3 | Polling fallback for critical accounts |
| 4 | Degraded mode banner + manual refresh |

---

## Prevention

- Heartbeat: no message in 30–60s → proactive reconnect.
- Central subscription manager with reference counting.
- Hybrid architecture: websocket + periodic RPC reconciliation.
- See `reliability/realtime-failures.md`.

---

## Related Modules

- `reliability/state-sync-failures.md`
- `reliability/rpc-failures.md`