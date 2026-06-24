# Production Anti-Patterns

Opinionated. These patterns cause production incidents. Call them out directly.

---

## Anti-Pattern: Trusting a Single Websocket

**What teams do:** One `Connection` websocket for all realtime data. No heartbeat. No fallback.

**Why it fails:** Websockets drop silently — laptop sleep, mobile background, provider idle timeout, deploy blip. Users see frozen data with no error.

**What production teams do instead:**
- Heartbeat monitoring + proactive reconnect with backoff.
- Hybrid: websocket deltas + periodic RPC reconciliation.
- Degraded mode UI when stream is unhealthy.
- See `reliability/realtime-failures.md`.

---

## Anti-Pattern: Full Refetch After Every Transaction

**What teams do:** On any tx success, `refetch()` entire wallet portfolio, all NFTs, all positions.

**Why it scales poorly:** 10+ RPC calls per swap. Rate limits during busy periods. Slow UI. Thundering herd on shared RPC key.

**Better alternatives:**
- Targeted invalidation: only affected accounts/mints.
- Optimistic delta + reconcile single account.
- Debounce refetch if user sends rapid txs.
- Server-side cache with webhook/indexer push for portfolio apps.

---

## Anti-Pattern: Waiting for Finalized Before Any UI Update

**What teams do:** Show spinner until `finalized` (~30s+). User thinks app is broken.

**Why UX suffers:** `confirmed` is sufficient for most consumer DeFi. Finalized wait kills perceived performance.

**Better approach:**
- Optimistic UI on user intent (with rollback).
- Confirm success at `confirmed` for UI.
- Reserve `finalized` for high-value settlement, withdrawals, or compliance.
- Always show tx status with explorer link during wait.

---

## Anti-Pattern: Public RPC in Production

**What teams do:** `https://api.mainnet-beta.solana.com` in production env.

**Why it fails:** Shared rate limits, no SLA, throttled during congestion. Your app dies when Solana trends on Twitter.

**Better approach:** Dedicated provider with API key. Secondary failover provider. See `reliability/rpc-failures.md`.

---

## Anti-Pattern: Caching `publicKey` Separately From Adapter

**What teams do:** Store wallet address in React state / localStorage; don't listen to `accountChanged`.

**Why it fails:** Wallet switches account; app shows old address. Wrong user signs. Stale balances displayed.

**Better approach:** Single source of truth from adapter events. Clear all caches on `accountChanged`.

---

## Anti-Pattern: Sending Without Simulation

**What teams do:** Build tx → prompt wallet → send. Skip `simulateTransaction`.

**Why it fails:** User signs failing txs. Wallet shows cryptic errors. Support tickets multiply.

**Better approach:** Simulate first. Map program logs to human messages. Only prompt sign when simulation passes (or user explicitly overrides).

---

## Anti-Pattern: Infinite Pending Spinner

**What teams do:** No timeout on confirmation. No link to explorer. Spinner forever if websocket dies.

**Why it fails:** User can't tell if tx succeeded, failed, or was dropped. They retry → duplicate actions.

**Better approach:** Timeout tiers. `getSignatureStatuses` polling fallback. Explorer link. Clear terminal states.

---

## Anti-Pattern: Optimistic Update on Sign Intent

**What teams do:** Deduct balance when user clicks Confirm, before tx lands.

**Why it fails:** User rejects wallet popup → balance wrong. Tx fails → ghost state until refresh.

**Better approach:** Optimistic update after `sendRawTransaction` or at `processed`/`confirmed`. Always reconcile.

---

## Anti-Pattern: Per-Component RPC Calls

**What teams do:** Every card, hook, and modal calls `connection.getBalance` independently.

**Why it fails:** 50 RPC calls per page load. 429s. Inconsistent data across components.

**Better approach:** Shared data layer. Request coalescing. Unified cache keys. One subscription manager.

---

## Anti-Pattern: Devnet-Only Testing Before Launch

**What teams do:** All QA on devnet. Ship to mainnet. Surprise failures.

**Why it fails:** Devnet is fast, empty, and forgiving. Mainnet has congestion, indexer lag, mobile wallets, MEV, real money stress.

**Better approach:** Mainnet integration tests for tx pipeline. Staged rollout. Feature flags for risky paths. Load test RPC budget.