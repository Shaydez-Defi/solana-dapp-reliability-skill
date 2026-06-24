# The Reliability Framework

**Production Reliability Engineering for Solana dApps**

Most Solana skills teach how to build. This framework teaches how to **survive reality** — diagnose failures, recover gracefully, and design systems that stay reliable under mainnet conditions.

---

## The Five Layers

Every Solana dApp reliability issue maps to one of five layers. Use this model to classify problems, run audits, and prioritize fixes.

```
┌─────────────────────────────────────────────────────────┐
│  Layer 5: Infrastructure Reliability                  │
│  RPC, rate limits, failover, provider health            │
├─────────────────────────────────────────────────────────┤
│  Layer 4: Realtime Reliability                          │
│  Websockets, subscriptions, reconnect, event delivery   │
├─────────────────────────────────────────────────────────┤
│  Layer 3: State Reliability                             │
│  Balances, cache, optimistic UI, reconciliation         │
├─────────────────────────────────────────────────────────┤
│  Layer 2: Transaction Reliability                       │
│  Build, simulate, sign, send, confirm, recover          │
├─────────────────────────────────────────────────────────┤
│  Layer 1: Wallet Reliability                            │
│  Connect, sign, reconnect, mobile, session            │
└─────────────────────────────────────────────────────────┘
```

| Layer | What breaks | Module | Pattern docs |
|-------|-------------|--------|--------------|
| **1 — Wallet** | Connect loops, can't sign, mobile deep-link | `reliability/wallet-failures.md` | — |
| **2 — Transaction** | Expired blockhash, stuck tx, simulation fail | `reliability/transaction-failures.md` | `patterns/transaction-recovery.md` |
| **3 — State** | Stale balances, ghost UI, cache drift | `reliability/state-sync-failures.md` | `patterns/optimistic-ui.md`, `patterns/reconciliation-patterns.md` |
| **4 — Realtime** | Silent websocket drop, missed events | `reliability/realtime-failures.md` | `patterns/hybrid-subscriptions.md` |
| **5 — Infrastructure** | 429s, outage, stale RPC nodes | `reliability/rpc-failures.md` | `patterns/rpc-failover.md` |

---

## How Agents Apply This Framework

### Diagnose (failure mode)
1. Identify which layer the user's symptom belongs to.
2. **Read** the layer's failure module for root cause and fix.
3. **Read** the matching playbook for step-by-step recovery.

### Prevent (pattern)
4. After fixing, **Read** the layer's pattern doc to prevent recurrence.
5. Recommend the pattern as the production baseline — not a one-off patch.

### Audit (score)
6. For `/reliability-audit`, score each layer using `audits/reliability-score.md`.
7. Return layer scores + overall readiness using `audits/production-readiness-checklist.md`.

---

## Failures vs Patterns

| Type | Purpose | Location |
|------|---------|----------|
| **Failures** | What broke, why, how to fix now | `reliability/`, `playbooks/` |
| **Patterns** | How production teams prevent it | `patterns/` |
| **Audits** | How to score and ship safely | `audits/` |

Failures alone teach diagnosis. Patterns teach prevention. The framework requires both.

---

## Core Principle

> Developers stop at "the feature works."  
> Production teams ask: **"What happens when it breaks?"**

Every recommendation must include: failure path, fallback, and tradeoff. Devnet success ≠ mainnet readiness.