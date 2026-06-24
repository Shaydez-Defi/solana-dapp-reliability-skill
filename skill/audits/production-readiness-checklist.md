# Production Readiness Checklist

**Founder question:** *Is my dApp ready for mainnet users?*

Use this checklist in `/reliability-audit` or when a team asks about launch readiness. Every item should be checked against **mainnet**, not devnet.

---

## Layer 1: Wallet Reliability

- [ ] Wallet adapters registered (Phantom, Backpack, or target wallets)
- [ ] `WalletProvider` stable at app root — no remount on route change
- [ ] Wallet recovery tested: disconnect → reconnect without page refresh
- [ ] Mobile wallet tested (iOS Safari + Android Chrome)
- [ ] In-app browser detection (Twitter/Discord) with fallback prompt
- [ ] `accountChanged` clears all wallet-scoped caches
- [ ] User rejection shows clear message — not generic error

---

## Layer 2: Transaction Reliability

- [ ] `simulateTransaction` runs before every wallet sign prompt
- [ ] Blockhash fetched as late as possible; rebuilt on expiry
- [ ] Transaction retry strategy documented (resubmit vs re-sign)
- [ ] Submit button disabled during in-flight transaction
- [ ] Duplicate submission guard (debounce + idempotency)
- [ ] Confirmation at `confirmed` with timeout + `getSignatureStatuses` fallback
- [ ] All tx states have explorer links (pending, success, failed)
- [ ] Compute budget set from simulation on complex routes

---

## Layer 3: State Reliability

- [ ] Optimistic updates reconciled against RPC within 2 seconds
- [ ] Rollback on tx failure, rejection, or timeout
- [ ] Cache keys scoped to `pubkey` + entity (mint, account, etc.)
- [ ] Post-tx invalidation fires at `confirmed` — not only on refresh
- [ ] Single data layer — no competing React Query + SWR + local state for same entity
- [ ] Manual refresh recovers stale UI without full page reload
- [ ] Indexer + RPC hybrid for balances that just changed

---

## Layer 4: Realtime Reliability

- [ ] Websocket reconnect strategy exists (backoff + jitter)
- [ ] Heartbeat detects silent disconnects (no message in 30–60s)
- [ ] Full RPC snapshot on reconnect before trusting stream
- [ ] Subscription cleanup on component unmount — no listener leaks
- [ ] Polling fallback when websocket unhealthy >60s
- [ ] Degraded mode banner when live data is stale

---

## Layer 5: Infrastructure Reliability

- [ ] RPC failover configured (minimum 2 independent providers)
- [ ] Not using public `api.mainnet-beta.solana.com` in production
- [ ] Rate limits handled (backoff on 429, request coalescing)
- [ ] Health check loop monitors slot lag and p95 latency
- [ ] Circuit breaker prevents retry storms during outage
- [ ] Env-based RPC config — nothing hardcoded in client bundle

---

## Launch Decision Matrix

| Checked items | Verdict |
|---------------|---------|
| 90–100% | Ready for mainnet users |
| 75–89% | Soft launch with monitoring; fix gaps within 2 weeks |
| 60–74% | Staged rollout only; high support load expected |
| <60% | Not ready — users will hit failures daily |

---

## Quick Founder Summary Template

```markdown
## Mainnet Readiness: [App Name]

**Checklist:** 28/35 items passed (80%)
**Reliability Score:** 74/100 (Solid)
**Verdict:** Soft launch OK — fix State layer before marketing push.

### Blockers (must fix)
- [ ] ...

### Before scale (fix within 2 weeks)
- [ ] ...

### Monitoring to add on launch
- balance_lag_seconds
- ws_reconnect_count
- rpc_error_rate
- tx_confirmation_time_p95
```