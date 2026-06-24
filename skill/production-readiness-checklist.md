# Production Readiness Checklist

**Founder question:** *Is my dApp ready for mainnet users?*

Check every item against **mainnet**, not devnet.

---

## Checklist

- [ ] Wallet recovery tested (disconnect → reconnect without refresh)
- [ ] Mobile wallet tested (iOS Safari + Android Chrome)
- [ ] RPC failover configured (2+ providers)
- [ ] WebSocket recovery configured (reconnect + resubscribe)
- [ ] Optimistic updates reconciled (RPC within 2s, rollback on failure)
- [ ] Retry logic exists (backoff, not blind loops)
- [ ] Rate limits handled (429 backoff, no public mainnet RPC)
- [ ] Transaction failure UX exists (rejection, timeout, dropped — not infinite spinner)
- [ ] Indexer lag handled (RPC fallback after recent tx)
- [ ] State reconciliation implemented (UI matches chain)

---

## By Layer

| Layer | Items above |
|-------|-------------|
| 1 — Wallet | Wallet recovery, mobile wallet |
| 2 — Transaction | Retry logic, transaction failure UX |
| 3 — State | Optimistic reconciled, indexer lag, state reconciliation |
| 4 — Realtime | WebSocket recovery |
| 5 — Infrastructure | RPC failover, rate limits |

---

## Verdict

| Passed | Decision |
|--------|----------|
| 9–10 | Ready for mainnet users |
| 7–8 | Soft launch with monitoring |
| 5–6 | Staged rollout only |
| <5 | Not ready |

---

## Audit Output Template

```markdown
## Mainnet Readiness: [App Name]

**Checklist:** X/10 passed
**Layer scores:** Wallet / Tx / State / Realtime / Infra
**Overall:** XX/100
**Verdict:** [Ready / Soft launch / Not ready]

### Blockers
1. ...

### Fix first
1. ...
```