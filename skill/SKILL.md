---
name: solana-dapp-reliability
description: >
  Diagnose, prevent, and recover from production failures in Solana dApps.
  Apply the DApp Reliability Framework for stale balances, wallet issues,
  RPC outages, websocket drops, and tx failures. Use for /reliability-audit,
  production readiness, or mainnet launch reviews. Does NOT teach how to build
  dApps — the official Solana dev skill owns that.
metadata:
  author: Shaydez-Defi
  short-description: "Production failure diagnosis & recovery for Solana dApps"
---

# Solana dApp Reliability

This skill teaches AI agents how to **diagnose, prevent, and recover** from the failures that make Solana dApps unreliable in production.

**Not in scope:** how to build wallets, transactions, or React dApps — official Solana skills cover that.

---

## Load First

| Trigger | Read |
|---------|------|
| Audit, production readiness, reliability review | `reliability-framework.md` → `production-readiness-checklist.md` → `reliability-score.md` |
| Specific symptom | Playbook below, then failure module if needed |

**Rule:** Use **Read** tool. Max 2 files per debug turn. Max 3 for audits.

---

## Playbooks (first-class — load these for symptoms)

| Symptom | Playbook |
|---------|----------|
| Balance didn't update after tx | `playbooks/stale-balances.md` |
| Transaction frozen / spinner stuck | `playbooks/tx-stuck.md` |
| Wallet connected but can't sign | `playbooks/wallet-cannot-sign.md` |
| Live data stopped, no error | `playbooks/websocket-failure.md` |
| RPC down / 429 / nothing loads | `playbooks/rpc-outage.md` |

---

## Failure Modules (deep context)

- Layer 1 Wallet → `reliability/wallet-failures.md`
- Layer 2 Transaction → `reliability/transaction-failures.md`
- Layer 3 State → `reliability/state-sync-failures.md`
- Layer 4 Realtime → `reliability/realtime-failures.md`
- Layer 5 Infrastructure → `reliability/rpc-failures.md`

---

## Also Available

- Scoring rubric → `reliability-score.md`
- Anti-patterns → `anti-patterns/production-anti-patterns.md`
- web3.js → Kit migration → `migration/kit-migration.md`

---

## /reliability-audit

1. Read `reliability-framework.md`
2. Read `production-readiness-checklist.md`
3. Read `reliability-score.md`
4. Scan codebase — score 5 layers, run 10-item checklist
5. Output score block from `reliability-score.md` + verdict + top 3 blockers

---

## /tx-flow-audit

Trace button click → sign → confirm → UI update. Find every silent failure point.

1. Read `reliability-framework.md` (Layer 2)
2. Read `playbooks/tx-stuck.md`
3. Read `reliability/transaction-failures.md` if deeper context needed
4. Return: failure points by stage, layer score for Transaction Reliability, fixes

---

## /frontend-health-check

Architecture review focused on production survivability — not build patterns.

1. Read `reliability-framework.md`
2. Read `production-readiness-checklist.md`
3. Read `reliability-score.md`
4. Return: 5 layer scores, checklist X/10, strengths, weaknesses, top 3 risks

---

## /migrate-to-kit

Phased web3.js → @solana/kit migration without breaking production.

1. Read `migration/kit-migration.md`
2. Flag reliability risks per phase (wallet state, tx confirmation, cache invalidation)
3. Return: phased plan + which layers are affected each phase

---

## Response Rules

- Name the layer (1–5)
- Cite Severity / Frequency / User Impact from failure modules
- Playbook structure: Symptoms → Causes → Verification → Fixes → Prevention
- Devnet ≠ mainnet — say it explicitly