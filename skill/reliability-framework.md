# The DApp Reliability Framework

**Diagnose and recover from production failures in Solana dApps.**

The official Solana dev skill teaches how to build. This framework teaches how to **survive production**.

Load this file first for: audits, production readiness, reliability reviews, architecture reviews.

---

## Five Layers

Every issue maps to exactly one layer.

| Layer | Name | Failure module | Playbook |
|-------|------|----------------|----------|
| 1 | Wallet Reliability | `reliability/wallet-failures.md` | `playbooks/wallet-cannot-sign.md` |
| 2 | Transaction Reliability | `reliability/transaction-failures.md` | `playbooks/tx-stuck.md` |
| 3 | State Reliability | `reliability/state-sync-failures.md` | `playbooks/stale-balances.md` |
| 4 | Realtime Reliability | `reliability/realtime-failures.md` | `playbooks/websocket-failure.md` |
| 5 | Infrastructure Reliability | `reliability/rpc-failures.md` | `playbooks/rpc-outage.md` |

---

## Agent Workflow

### Debug a failure
1. Classify symptom → layer
2. **Read** matching **playbook** first (step-by-step recovery)
3. **Read** failure module if deeper context needed
4. Max 2 files per turn

### Audit / production readiness
1. **Read** `production-readiness-checklist.md`
2. **Read** `reliability-score.md` — scoring rubric + required output format
3. Scan codebase against checklist
4. Return: 5 layer scores, overall score, checklist X/10, verdict, top 3 fixes

---

## Core Principle

> Developers stop at "the feature works."  
> Production teams ask: **"What happens when it breaks?"**

Devnet success ≠ mainnet readiness. Every fix needs a fallback. Never compete with the official dev skill on *how to build* — own *how to recover*.