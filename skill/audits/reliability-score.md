# Reliability Score Methodology

A structured scoring system AI agents apply during `/reliability-audit` and `/frontend-health-check`.

Not code — **methodology**. Makes the skill a product, not notes.

---

## The Five Layer Scores (0–100 each)

| Layer | Score name | What it measures |
|-------|------------|------------------|
| 1 | **Wallet Reliability** | Connect stability, reconnect, mobile, cache invalidation on switch |
| 2 | **Transaction Reliability** | Simulation, blockhash, confirmation, errors, idempotency |
| 3 | **State Reliability** | Optimistic UI, reconciliation, cache keys, stale data recovery |
| 4 | **Realtime Reliability** | Websocket health, subscriptions, reconnect, hybrid fallback |
| 5 | **Infrastructure Reliability** | Multi-RPC, failover, rate limits, health monitoring |

**Overall Reliability Score** = average of five layers (equal weight unless user specifies priorities).

---

## How to Calculate Each Layer

For each layer, start at **100** and deduct points for missing capabilities.

### Layer 1: Wallet Reliability

| Check | Deduction if missing |
|-------|---------------------|
| Wallet adapters registered and tested | −25 |
| Single stable `WalletProvider` at root | −15 |
| `accountChanged` clears wallet-scoped caches | −15 |
| Connect guarded against loops / duplicate calls | −15 |
| Mobile tested (Phantom, Safari, deep-link) | −15 |
| User rejection vs network error distinguished | −10 |
| WalletConnect session restore on reload | −5 |

### Layer 2: Transaction Reliability

| Check | Deduction if missing |
|-------|---------------------|
| `simulateTransaction` before wallet prompt | −20 |
| Fresh blockhash fetched late; rebuild on expiry | −15 |
| Confirmation at `confirmed` with timeout fallback | −15 |
| Submit disabled during in-flight tx | −10 |
| Idempotency / duplicate submission guard | −15 |
| User-facing error mapping for program errors | −10 |
| Compute budget set from simulation | −10 |
| Explorer link on all tx states | −5 |

### Layer 3: State Reliability

| Check | Deduction if missing |
|-------|---------------------|
| Cache keys include pubkey + entity ID | −15 |
| Post-tx invalidation at `confirmed` | −20 |
| Optimistic updates reconciled within 2s | −20 |
| Rollback on tx failure / timeout | −15 |
| Single data layer (no competing caches) | −15 |
| Periodic reconciliation for critical balances | −10 |
| Hybrid indexer + RPC for post-tx reads | −5 |

### Layer 4: Realtime Reliability

| Check | Deduction if missing |
|-------|---------------------|
| Websocket heartbeat / stale detection | −20 |
| Reconnect with exponential backoff | −15 |
| Resubscribe + RPC snapshot on reconnect | −15 |
| Subscription cleanup (no memory leaks) | −15 |
| Polling fallback when websocket unhealthy | −20 |
| User-visible degraded state | −10 |
| Central subscription manager | −5 |

### Layer 5: Infrastructure Reliability

| Check | Deduction if missing |
|-------|---------------------|
| Dedicated RPC with API key (not public) | −25 |
| Secondary failover provider configured | −20 |
| Health check loop (slot lag, latency) | −15 |
| Retry with backoff on 429/5xx | −15 |
| Circuit breaker prevents retry storms | −10 |
| Request coalescing for duplicate reads | −10 |
| Env-based endpoints (no hardcoding) | −5 |

---

## Score Interpretation

| Score | Level | Recommendation |
|-------|-------|----------------|
| 85–100 | **Production-ready** | Ship with monitoring; minor gaps only |
| 70–84 | **Solid** | Ship with caution; fix High-severity gaps first |
| 50–69 | **Fragile** | Not ready for mainnet traffic at scale |
| <50 | **Critical** | Block mainnet launch until Layer 1–3 addressed |

---

## Example Output

```markdown
## Reliability Score: MyDeFi App

| Layer | Score | Top Gap |
|-------|-------|---------|
| Wallet Reliability | 80/100 | Mobile deep-link untested |
| Transaction Reliability | 65/100 | No simulation pre-flight |
| State Reliability | 55/100 | Optimistic UI without rollback |
| Realtime Reliability | 70/100 | No polling fallback |
| Infrastructure Reliability | 90/100 | Single provider, no failover tested |
| **Overall** | **72/100** | **Fragile — fix State + Tx before scale** |

### Priority fixes (by user impact)
1. Add optimistic reconcile + rollback (Layer 3)
2. Simulate before sign (Layer 2)
3. Test mobile wallet connect (Layer 1)
```

---

## Agent Instructions

1. Scan the codebase against each layer's deduction table.
2. Be honest — devnet-only patterns score low.
3. Cite file paths for each deduction.
4. Rank fixes by **user impact**, not code elegance.
5. Cross-reference `patterns/` for prevention after scoring.