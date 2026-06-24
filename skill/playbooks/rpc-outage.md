# Playbook: RPC Outage

**User report:** "Nothing loads" / "All transactions fail" / app-wide failure.

**Severity:** Critical — entire dApp non-functional for all users.

---

## Investigation (2 minutes)

1. **Scope the failure**
   - Reads failing, writes failing, or both?
   - All users or one region?
   - Wallet still connects? (isolates RPC from wallet layer)

2. **Test endpoints**
   - `getHealth` / `getSlot` on primary provider.
   - Same call on backup provider.
   - `curl` from server if client-side works but server fails.

3. **Check operational causes**
   - API key revoked / quota exceeded?
   - Wrong env var in production deploy?
   - Provider status page incident?
   - 429 rate limit masquerading as outage?

4. **Check client behavior**
   - Retry storm making things worse?
   - All components sharing one broken endpoint?

---

## Fallback Procedures

### Immediate (ops)
1. Switch primary → secondary provider in config / env.
2. Deploy or toggle feature flag if using runtime provider config.
3. Enable read-only degraded mode if writes can't fail over cleanly.

### Immediate (user-facing)
1. Banner: "Network connectivity issues — some features may be slow."
2. Preserve user input; don't clear forms on RPC errors.
3. Queue retry for failed reads with backoff — don't spam.

### If both providers down
1. Show cached data with staleness timestamp (if available).
2. Disable write actions with clear explanation.
3. Link to status page / Discord for updates.

---

## Multi-RPC Strategy

```
Primary (sends + reads) ──▶ unhealthy? ──▶ Secondary
                              │
                              ▼
                         both unhealthy?
                              │
                              ▼
                    Degraded mode (cache + polling + banner)
```

### Config checklist
- [ ] Two independent providers (different infra vendors ideal)
- [ ] Env vars for all endpoints — nothing hardcoded
- [ ] Health check loop (slot lag + latency)
- [ ] Circuit breaker after N consecutive failures
- [ ] Automatic cache invalidation on provider switch

---

## Prevention

- Never use public mainnet RPC in production.
- Monitor p95 latency and error rate per provider.
- Run game-day drill: disable primary, verify failover < 30s.
- See `reliability/rpc-failures.md`.

---

## Related Modules

- `reliability/transaction-failures.md` (if only sends fail)
- `reliability/realtime-failures.md` (if only websocket fails)