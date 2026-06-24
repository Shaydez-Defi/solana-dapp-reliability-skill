# Reliability Score

**The output artifact.** Every `/reliability-audit` must produce these five layer scores plus an overall.

Load with `reliability-framework.md` and `production-readiness-checklist.md`.

---

## How to Score (0–100 per layer)

Start at **100**. Deduct for each gap found in the codebase. Be harsh — devnet-only configs score low on mainnet criteria.

| Layer | What to inspect | Key deductions |
|-------|-----------------|----------------|
| **Wallet Reliability** | Adapters registered, reconnect flow, mobile tested, single provider | −25 no adapters · −20 no reconnect · −15 no mobile test · −10 multiple WalletProviders |
| **Transaction Reliability** | Simulation, confirmation UX, error handling, retry logic | −25 errors swallowed · −20 no simulation · −15 infinite spinner · −10 no retry/backoff |
| **State Reliability** | Post-tx invalidation, reconciliation, optimistic rollback, indexer fallback | −25 no reconciliation · −20 stale after tx · −15 optimistic never rolled back · −10 indexer-only, no RPC fallback |
| **Realtime Reliability** | Websocket subscriptions, reconnect + resubscribe, hybrid RPC fallback | −30 no subscriptions · −20 no reconnect · −15 polling-only with no heartbeat · −10 silent freeze |
| **Infrastructure Reliability** | RPC failover, rate-limit handling, health checks | −30 single public RPC · −20 no failover · −15 no 429 backoff · −10 devnet endpoint in prod |

**Floor:** 0. **Ceiling:** 100. Round to nearest integer.

---

## Overall Score

Weighted average of the five layers:

| Layer | Weight |
|-------|--------|
| Wallet | 20% |
| Transaction | 25% |
| State | 20% |
| Realtime | 15% |
| Infrastructure | 20% |

`Overall = (Wallet×0.20) + (Transaction×0.25) + (State×0.20) + (Realtime×0.15) + (Infrastructure×0.20)`

Round to nearest integer.

---

## Verdict

| Overall | Meaning |
|---------|---------|
| 85+ | Production-ready |
| 70–84 | Soft launch OK |
| 50–69 | Fragile |
| <50 | Not mainnet-ready |

Cross-check with checklist: **9–10/10** = ready · **<5/10** = not ready regardless of score.

---

## Required Audit Output

Always return this block first:

```
Wallet Reliability:          XX
Transaction Reliability:     XX
State Reliability:           XX
Realtime Reliability:        XX
Infrastructure Reliability:  XX
────────────────────────────────
Overall Score:               XX

Checklist: X/10 passed
Verdict: [Ready / Soft launch / Fragile / Not ready]
```

Then: top 3 blockers ranked by user impact, with layer + playbook/fix reference.