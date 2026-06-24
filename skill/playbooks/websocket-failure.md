# Playbook: Realtime Data Stopped

**Layer 4 — Realtime Reliability**

**Severity:** High | **Frequency:** Very Common | **User Impact:** High

---

## Symptoms

- Prices/balances frozen; no error shown
- Refresh fixes instantly
- Users think the protocol is dead

## Likely Causes

- Silent websocket disconnect (no heartbeat)
- Subscriptions not cleaned up; duplicate listeners after reconnect
- Tab backgrounded; browser throttled timers
- Provider idle timeout or maintenance

## Verification Steps

1. `readyState === OPEN`? Last message timestamp?
2. Count active subscriptions — should not grow unbounded
3. RPC-fetch same account — fresh on RPC, stale on UI = transport issue
4. Reproduce: laptop sleep, mobile background, VPN toggle

## Fixes

1. Force reconnect + resubscribe all accounts
2. RPC snapshot all critical state before trusting stream
3. Show "Reconnecting to live data…" — not silent recovery
4. After 3 failed reconnects → polling fallback (15–30s)
5. Remove duplicate listeners before resubscribing

## Prevention

- Heartbeat: no message in 30–60s → proactive reconnect with backoff
- Central subscription manager with reference counting
- Periodic RPC reconcile every 15–30s regardless of websocket health
- Metric: `ws_last_message_age_seconds`; alert if >60s

**Module:** `reliability/realtime-failures.md`