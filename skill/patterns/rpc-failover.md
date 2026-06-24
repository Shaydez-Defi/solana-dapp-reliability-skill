# Pattern: RPC Failover

**Layer 5 — Infrastructure Reliability**

One RPC provider is a single point of failure. Production dApps route around failure.

---

## Minimum Production Config

- **Primary** provider with dedicated API key
- **Secondary** provider (different vendor ideal)
- **Health check** loop every 10–30s
- **Circuit breaker** after N consecutive failures
- **Env-based** URLs — never hardcode in client

---

## Health-Aware Router

```typescript
// Conceptual — adapt to your stack
async function rpcCall<T>(method: string, params: unknown[]): Promise<T> {
  const provider = selectHealthyProvider() // lowest lag, passing health check
  try {
    return await provider.request(method, params)
  } catch (e) {
    if (isRetryable(e)) {
      markUnhealthy(provider)
      return await fallbackProvider.request(method, params)
    }
    throw e
  }
}
```

### Health Signals

| Signal | Threshold | Action |
|--------|-------------|--------|
| `getSlot` lag | >30 slots behind reference | Deprioritize provider |
| p95 latency | >2s on `getLatestBlockhash` | Failover reads |
| 429 rate | >5% of requests | Backoff + shift traffic |
| 503 / connection refused | Any | Immediate failover |

---

## Routing by Operation Type

| Operation | Provider selection |
|-----------|-------------------|
| Reads (balances, accounts) | Lowest-lag healthy node |
| Sends (`sendTransaction`) | Most reliable (not necessarily fastest) |
| Subscriptions | Dedicated WS endpoint; may differ from HTTP |
| After failover | Invalidate all cached RPC data |

---

## Retry Policy

- **Reads:** exponential backoff, max 3–5 retries, coalesce duplicates
- **Sends:** check `getSignatureStatuses` before resending; never blind retry loops
- **Global:** circuit breaker — if both providers fail → degraded mode + user banner

---

## Related

- Failures: `reliability/rpc-failures.md`
- Playbook: `playbooks/rpc-outage.md`
- Audit: `audits/production-readiness-checklist.md` (Infrastructure section)