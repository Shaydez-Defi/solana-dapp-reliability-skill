# Command: /reliability-audit

Full codebase reliability review.

---

## When to Run

User asks to audit, review, or score their Solana dApp for production readiness.

## Steps

1. Read `rules/reliability-rules.md`.
2. Read `skill/audits/reliability-checklist.md`.
3. Scan the codebase for:
   - Wallet adapter setup and event handling
   - Transaction build → simulate → sign → send → confirm pipeline
   - Data fetching, caching, and invalidation patterns
   - Websocket / subscription usage
   - RPC endpoint configuration and error handling
   - Error states and user messaging

4. Score each category 0–100 using the checklist. Be honest — devnet-only patterns score low.

5. Output using the audit template from `reliability-checklist.md`.

6. For each finding, reference the relevant module:
   - Wallet issues → `skill/reliability/wallet-failures.md`
   - Tx issues → `skill/reliability/transaction-failures.md`
   - State issues → `skill/reliability/state-sync-failures.md`
   - Realtime → `skill/reliability/realtime-failures.md`
   - RPC → `skill/reliability/rpc-failures.md`
   - Anti-patterns → `skill/anti-patterns/production-anti-patterns.md`

## Rules

- Cite specific files and line patterns when possible.
- Rank recommendations by **user impact**, not code elegance.
- Distinguish "works on devnet" from "production-ready."
- Include at least one quick win and one strategic improvement.