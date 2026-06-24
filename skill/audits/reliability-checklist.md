# Reliability Checklist & Score Framework

Use with `/reliability-audit`, `/tx-flow-audit`, and `/frontend-health-check`.

---

## Scoring Categories (0–100 each)

| Category | What it measures |
|----------|------------------|
| **Wallet Reliability** | Connect stability, reconnect handling, mobile support, cache invalidation on switch |
| **Transaction Reliability** | Simulation, blockhash freshness, confirmation strategy, error messaging, idempotency |
| **State Consistency** | Optimistic updates, reconciliation, cache key discipline, stale data recovery |
| **Realtime Reliability** | Websocket health, subscription cleanup, reconnect, hybrid fallback |
| **RPC Reliability** | Multi-provider, rate limit handling, backoff, health monitoring |
| **Failure Recovery** | Degraded modes, user messaging, manual recovery paths, playbooks followed |

**Overall Reliability** = weighted average (equal weights unless user specifies priorities).

---

## Wallet Reliability Checklist

- [ ] Single `WalletProvider` at app root, stable across routes
- [ ] UI syncs from adapter events, not cached pubkey
- [ ] `accountChanged` clears wallet-scoped caches
- [ ] Connect guarded against duplicate calls / loops
- [ ] Mobile tested (Phantom, Safari, deep-link return)
- [ ] WalletConnect session restore on page load
- [ ] Clear error on user rejection vs network failure
- [ ] Disconnect fully resets state

**Red flags:** reconnect loop, multiple providers, pubkey in localStorage without event sync.

---

## Transaction Reliability Checklist

- [ ] `simulateTransaction` before wallet prompt
- [ ] Blockhash fetched late; rebuild on expiry
- [ ] Compute budget set from simulation
- [ ] Priority fee strategy documented
- [ ] Confirmation at `confirmed` for UI (not only `finalized`)
- [ ] Timeout + `getSignatureStatuses` fallback
- [ ] Submit button disabled during in-flight tx
- [ ] Idempotency / duplicate submission guards
- [ ] User-facing error mapping for common program errors

**Red flags:** no simulation, infinite spinner, no blockhash refresh, double-submit on retry.

---

## State Consistency Checklist

- [ ] Cache keys include wallet pubkey + entity identifiers
- [ ] Post-tx invalidation at `confirmed`
- [ ] Optimistic updates reconciled within 2s
- [ ] Rollback on tx failure / timeout
- [ ] Single data layer (no competing caches)
- [ ] Periodic reconciliation for critical balances
- [ ] Indexer + RPC hybrid for post-tx reads
- [ ] Slot/version guard on out-of-order updates

**Red flags:** balance differs across pages, optimistic without rollback, full refetch only recovery.

---

## Realtime Reliability Checklist

- [ ] Websocket heartbeat / stale detection
- [ ] Reconnect with exponential backoff
- [ ] Resubscribe + RPC snapshot on reconnect
- [ ] Subscription cleanup on unmount (no leaks)
- [ ] Central subscription manager
- [ ] Polling fallback when websocket unhealthy
- [ ] User-visible degraded state

**Red flags:** silent disconnect, growing listener count, no fallback transport.

---

## RPC Reliability Checklist

- [ ] Dedicated provider with API key (not public endpoint)
- [ ] Secondary failover provider configured
- [ ] Health check loop (slot lag, latency)
- [ ] Retry with backoff on 429/5xx
- [ ] Circuit breaker prevents retry storms
- [ ] Request coalescing for duplicate reads
- [ ] Env-based endpoint config

**Red flags:** hardcoded public RPC, no failover, unbounded retries.

---

## Failure Recovery Checklist

- [ ] Degraded mode banner for network issues
- [ ] Manual refresh recovers without full page reload
- [ ] Explorer links on all tx states
- [ ] Playbook-documented paths for top 5 incidents
- [ ] Metrics: balance lag, ws reconnects, RPC errors
- [ ] Devnet assumptions flagged in docs

**Red flags:** blank screen on RPC error, no user messaging, only fix is refresh.

---

## Score Interpretation

| Score | Level | Meaning |
|-------|-------|---------|
| 85–100 | Production-ready | Minor gaps only |
| 70–84 | Solid | Some production risk under load |
| 50–69 | Fragile | Will break in real usage |
| <50 | Critical | Not production-ready |

---

## Audit Output Template

```markdown
## Reliability Audit: [Project Name]

| Category | Score | Top Issue |
|----------|-------|-----------|
| Wallet Reliability | /100 | |
| Transaction Reliability | /100 | |
| State Consistency | /100 | |
| Realtime Reliability | /100 | |
| RPC Reliability | /100 | |
| Failure Recovery | /100 | |
| **Overall** | **/100** | |

### Critical Findings
1. ...

### Recommendations (ranked by user impact)
1. ...

### Quick Wins (< 1 day)
- ...

### Strategic Improvements (> 1 week)
- ...
```