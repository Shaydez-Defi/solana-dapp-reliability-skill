# Command: /reliability-audit

Full codebase reliability review using **The Reliability Framework**.

---

## When to Run

- User asks to audit, review, or score their Solana dApp
- User asks: *"Is my dApp ready for mainnet users?"*
- Pre-launch production readiness review

## Steps

1. **Read** `framework/reliability-framework.md` (five layers).
2. **Read** `rules/reliability-rules.md`.
3. **Read** `audits/reliability-score.md` — scoring methodology.
4. **Read** `audits/production-readiness-checklist.md` — launch checklist.
5. Scan the codebase across all five layers.
6. Score each layer 0–100 using deduction tables in `reliability-score.md`.
7. Return:
   - Five layer scores + overall score
   - Production readiness checklist (passed / total)
   - Launch verdict (ready / soft launch / not ready)
   - Priority fixes ranked by user impact
8. For each finding, **Read** the relevant failure module; recommend the matching **pattern** doc.

## Layer → Module Map

| Layer | Failures | Patterns |
|-------|----------|----------|
| 1 Wallet | `reliability/wallet-failures.md` | — |
| 2 Transaction | `reliability/transaction-failures.md` | `patterns/transaction-recovery.md` |
| 3 State | `reliability/state-sync-failures.md` | `patterns/optimistic-ui.md`, `patterns/reconciliation-patterns.md` |
| 4 Realtime | `reliability/realtime-failures.md` | `patterns/hybrid-subscriptions.md` |
| 5 Infrastructure | `reliability/rpc-failures.md` | `patterns/rpc-failover.md` |

## Rules

- Cite specific files and line patterns when possible.
- State Severity / Frequency / User Impact for top findings.
- Distinguish devnet assumptions from mainnet readiness.
- Include one quick win and one strategic improvement per layer with gaps.