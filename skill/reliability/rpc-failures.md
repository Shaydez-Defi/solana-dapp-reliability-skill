# RPC Failures

Rate limits, provider degradation, and outage survival.

---

## Problem: Rate Limiting (HTTP 429)

### Symptoms
- Intermittent `429 Too Many Requests`.
- Some users see data; others get errors.
- Worse during market events or airdrop claims.

### Likely Causes
- Free/public RPC shared across all users.
- Client-side fan-out: every component calls RPC independently.
- Aggressive polling without backoff.
- Websocket + HTTP hitting same quota.

### Diagnosis
1. Identify RPC endpoint — shared or per-user API key?
2. Count requests per page load (Network tab or server logs).
3. Check for retry loops amplifying traffic.
4. Correlate 429s with user count and time of day.

### Fix
- Move to dedicated provider with API key (Helius, Triton, QuickNode).
- Request coalescing: dedupe identical in-flight RPC calls.
- Backoff on 429: respect `Retry-After` header if present.
- Route reads through backend proxy with caching.

### Prevention
- Never ship production dApps on public `api.mainnet-beta.solana.com`.
- Rate budget per session; shed load gracefully.
- Cache immutable data (mint metadata, program IDs).

---

## Problem: Provider Degradation

### Symptoms
- Slow responses (2–10s) without hard errors.
- Timeouts before 429s appear.
- `getLatestBlockhash` intermittently fails.
- Confirmations take much longer than network average.

### Likely Causes
- Provider overloaded during congestion.
- Geographic latency to RPC region.
- Shared infrastructure noisy neighbor.
- Stale load balancer routing to unhealthy node.

### Diagnosis
1. Track p50/p95 latency per RPC method.
2. Compare same call across two providers.
3. Health check: `getHealth`, `getSlot` drift vs public explorer.
4. Monitor `isHealthy` if provider exposes it.

### Fix
- Automatic failover to secondary provider on latency threshold.
- Circuit breaker: after N failures, route all traffic to backup for M minutes.
- Reduce call volume: batch `getMultipleAccounts`.

### Prevention
- Multi-provider config from day one.
- See `playbooks/rpc-outage.md`.
- Alert on p95 latency > 2s for core methods.

---

## Problem: Hard Outage

### Symptoms
- All RPC calls fail: connection refused, 503, DNS errors.
- Entire app non-functional.
- Wallet connect works but all reads/writes fail.

### Likely Causes
- Provider incident.
- API key revoked or quota exhausted.
- Corporate firewall blocking endpoint.
- Wrong cluster URL in production env.

### Diagnosis
1. Verify endpoint URL and network (mainnet vs devnet).
2. Test provider status page / third-party uptime.
3. Confirm API key valid and billing current.
4. `curl` health endpoint from server and client environments.

### Fix
- Immediate failover to backup provider.
- Read-only degraded mode: show cached data + "network issues" banner.
- Queue write operations with user consent to retry.

### Prevention
- Minimum two independent RPC providers.
- Env-based config with no hardcoded endpoints.
- Runbook: `playbooks/rpc-outage.md`.

---

## Problem: Retry Amplification

### Symptoms
- Brief outage becomes prolonged ban.
- RPC costs spike.
- Logs show identical requests hundreds of times per second.

### Likely Causes
- Retry without backoff on all errors.
- Every client retries independently (no server-side aggregation).
- React re-renders re-triggering failed fetches.

### Diagnosis
1. Search for `retry`, `refetch`, custom retry loops.
2. Count retry attempts per failed request in logs.
3. Check React Query / SWR retry config.

### Fix
- Exponential backoff with jitter: `min(cap, base * 2^attempt) + random()`.
- Max 3–5 retries for idempotent reads; 0–1 for sends.
- Circuit breaker at app level.

### Prevention
- Central RPC client with unified retry policy.
- Never retry `sendTransaction` blindly — use signature status check first.
- Distinguish idempotent reads from state-changing sends.

---

## Problem: Stale or Forked RPC Data

### Symptoms
- Account data differs between refresh and websocket.
- Tx confirmed on one provider, missing on another.
- Blockhash valid on app RPC but rejected by network.

### Likely Causes
- Provider on lagging node.
- Load balancer hitting nodes at different slots.
- Failover mid-session without state reset.

### Diagnosis
1. Compare `getSlot` across providers simultaneously.
2. Check slot lag > 30 behind network median.
3. Log provider identity with each response in debug mode.

### Fix
- Pin critical operations to lowest-lag provider.
- On failover, invalidate all cached RPC data.
- For sends: use provider with best `getHealth` at send time.

### Prevention
- Slot lag monitor; auto-deprioritize lagging endpoints.
- After provider switch, force full state refresh.

---

## Multi-RPC Architecture (Production Baseline)

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────┐
│   dApp UI   │────▶│  RPC Router      │────▶│  Primary    │
│             │     │  (health-aware)  │     │  Provider   │
└─────────────┘     │                  │────▶│  Secondary  │
                    │  - health check  │     │  Provider   │
                    │  - backoff       │     └─────────────┘
                    │  - coalescing    │
                    │  - circuit break │────▶ Polling fallback
                    └──────────────────┘
```

### Health Check Loop (every 10–30s)
- `getSlot` — compare against known good reference.
- `getHealth` — if available.
- Latency of `getLatestBlockhash`.

### Routing Rules
- **Reads**: lowest-lag healthy provider.
- **Sends**: most reliable provider (not necessarily fastest).
- **Subscriptions**: dedicated WS endpoint; separate from HTTP if needed.
- **Failover**: automatic; user never sees provider name unless debug mode.