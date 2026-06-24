# Realtime Failures

**Layer 4 — Realtime Reliability**

Websocket drops, subscription leaks, and silent data staleness.  
**Playbook:** `playbooks/websocket-failure.md`

---

## Problem: Silent Websocket Disconnect

**Severity:** High  
**Frequency:** Very Common  
**User Impact:** High — data frozen with no error; users think the app is dead.

### Symptoms
- UI looks live but data frozen for minutes.
- No error shown; users assume protocol is inactive.
- Refresh fixes instantly.

### Likely Causes
- No heartbeat / ping monitoring on connection.
- Idle timeout from RPC provider or load balancer.
- Tab backgrounded; browser throttled timers.
- Connection error swallowed without reconnect.

### Diagnosis
1. Log connect, disconnect, error, and last message timestamp.
2. Check if `onclose` triggers reconnection.
3. Measure time since last message when user reports stale UI.
4. Test laptop sleep, mobile background, VPN toggle.

### Fix
- Heartbeat: if no message in 30–60s, force reconnect.
- Surface degraded state: "Live data paused — reconnecting…"
- On reconnect: full resubscribe + RPC reconciliation snapshot.

### Prevention
- See `playbooks/websocket-failure.md`.
- Never assume websocket is alive without liveness checks.

---

## Problem: Dropped Events

**Severity:** High  
**Frequency:** Occasional (high load)  
**User Impact:** High — missed position/balance updates during active trading.

### Symptoms
- Missed account updates during high activity.
- Gaps in slot progression for subscribed accounts.
- Position changes on-chain not reflected in UI.

### Likely Causes
- Buffer overflow during burst traffic.
- Processing handler too slow; events dropped client-side.
- Reconnect gap between disconnect and resubscribe.

### Diagnosis
1. Compare event stream slot range against `getSlot` at reconnect.
2. Profile handler duration — blocking work in callback?
3. Check provider docs for at-least-once vs best-effort delivery.

### Fix
- Keep websocket handlers minimal — queue work off-thread.
- On reconnect, fetch full account state via RPC before resuming stream.
- Track `lastSeenSlot`; backfill if gap > threshold.

### Prevention
- Hybrid: websocket for deltas, periodic RPC snapshot for reconciliation.
- Alert on slot gap > 5 seconds during active session.

---

## Problem: Duplicate Events

**Severity:** Medium  
**Frequency:** Common (after reconnect)  
**User Impact:** Medium — UI flicker and wrong counters; rarely causes fund loss.

### Symptoms
- Balance flickers between two values.
- Same transaction notification shown twice.
- UI counters increment incorrectly.

### Likely Causes
- Overlapping subscriptions after reconnect without cleanup.
- At-least-once delivery from provider.
- React strict mode double-mount in dev leaking to prod patterns.

### Diagnosis
1. Count active subscriptions per account pubkey.
2. Log event signatures or content hashes; detect duplicates.
3. Check cleanup in `useEffect` return / `onUnmount`.

### Fix
- Deduplicate by `(pubkey, slot, dataHash)` before applying.
- Subscription manager: one listener per account, reference counted.
- Idempotent UI updates: set state to value, not increment blindly.

### Prevention
- Central subscription registry with explicit `subscribe` / `unsubscribe`.
- Integration test: connect → disconnect → reconnect → no duplicate listeners.

---

## Problem: Memory Leaks From Subscriptions

**Severity:** Medium  
**Frequency:** Occasional (long sessions)  
**User Impact:** Medium — degrades performance over long sessions; not immediate.

### Symptoms
- Tab slows after 30+ minutes.
- Memory grows with navigation.
- Thousands of websocket listeners in devtools.

### Likely Causes
- `onAccountChange` registered per component mount, never removed.
- Route changes add subscriptions without teardown.
- Global connection per hook instance instead of shared client.

### Diagnosis
1. Audit every `onAccountChange`, `onProgramAccountChange`, `logsSubscribe`.
2. Navigate 20 times; count listeners before/after.
3. Heap snapshot in Chrome DevTools.

### Fix
- Shared connection singleton at app level.
- Reference-counted subscriptions; unsubscribe when count hits zero.
- Strict cleanup in effect teardown.

### Prevention
- Ban raw subscription calls in leaf components — use data layer only.
- CI smoke test: memory stable after 50 route cycles.

---

## Problem: Reconnection Storm

**Severity:** Critical  
**Frequency:** Occasional  
**User Impact:** Critical — triggers RPC bans; makes outage worse than the original failure.

### Symptoms
- Hundreds of reconnect attempts per minute.
- RPC bans or rate limits the client.
- App becomes unusable after brief outage.

### Likely Causes
- Reconnect with no exponential backoff.
- Every component independently reconnecting.
- Retry on non-retryable errors (401, invalid API key).

### Diagnosis
1. Log reconnect attempts with reason codes.
2. Check if multiple modules each own a connection.
3. Correlate with RPC 429 responses.

### Fix
- Single reconnect coordinator with exponential backoff + jitter.
- Cap max retries; fall back to polling mode.
- Classify errors: auth failures → stop retry, show config error.

### Prevention
- Max 1 websocket connection per app per endpoint.
- Backoff: 1s → 2s → 4s → … → 60s cap.
- Switch to polling after N failed reconnects.

---

## Transport Comparison

| Transport | Strengths | Weaknesses | Best for |
|-----------|-----------|------------|----------|
| **WebSocket** (`accountSubscribe`, `logsSubscribe`) | Low latency, push updates | Silent drops, subscription management, provider limits | Active trading, live dashboards |
| **Yellowstone gRPC** | High throughput, program-level streams | Infra complexity, hosting cost | Indexers, market makers, backends |
| **Polling** (`getAccountInfo` on interval) | Simple, stateless, survives disconnects | Higher latency, RPC cost at scale | Fallback, low-frequency data |
| **Hybrid** | Resilient: stream + periodic reconcile | More code, two code paths | **Production dApps (recommended)** |

### Recommended Hybrid Pattern

1. **Primary**: websocket subscriptions for watched accounts.
2. **Heartbeat**: detect stale connection; reconnect with backoff.
3. **Reconcile**: every 15–30s, RPC snapshot for critical balances.
4. **Fallback**: if websocket unhealthy >60s, switch to polling until recovered.
5. **User signal**: show connection health indicator when degraded.