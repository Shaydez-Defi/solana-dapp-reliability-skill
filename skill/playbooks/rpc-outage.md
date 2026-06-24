# Playbook: RPC Outage

**Layer 5 — Infrastructure Reliability**

**Severity:** Critical | **Frequency:** Occasional | **User Impact:** Critical

---

## Symptoms

- Nothing loads; all txs fail
- 429 errors or connection refused
- Wallet still connects but reads/writes fail

## Likely Causes

- Provider incident or API key revoked
- Public RPC rate limited
- Wrong env var in production
- Retry storm making outage worse
- Single provider — no failover

## Verification Steps

1. Scope: reads only, writes only, or both?
2. `getSlot` on primary vs secondary provider
3. Provider status page / 429 in network tab?
4. `curl` endpoint from server and client
5. Check retry loops amplifying traffic

## Fixes

| Action | When |
|--------|------|
| Failover to secondary provider | Primary unhealthy |
| Degraded mode banner | Both slow but partially up |
| Stop retry storm | Circuit breaker + backoff |
| Read-only mode | Writes can't fail over safely |
| Queue writes with user consent | Extended outage |

## Prevention

- Minimum 2 independent RPC providers from day one
- Never use public mainnet RPC in production
- Health check: slot lag + p95 latency every 10–30s
- Game-day drill: kill primary, verify failover <30s

**Module:** `reliability/rpc-failures.md`