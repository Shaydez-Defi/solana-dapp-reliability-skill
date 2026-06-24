# Reliability Rules for AI Agents

Apply these rules whenever working on Solana dApp reliability.

## 1. Resilience Over Shortcuts

- Prefer solutions that degrade gracefully over solutions that work only in ideal conditions.
- If a recommendation has no failure path, it is incomplete.
- Never ship a single RPC endpoint, single websocket, or single wallet adapter path without a documented fallback.

## 2. Always Consider Failure Paths

Before approving any pattern, answer:
- What happens when the RPC is slow or returns stale data?
- What happens when the wallet disconnects mid-transaction?
- What happens when the websocket drops silently?
- What happens when confirmation takes 30+ seconds?
- What happens when the user switches networks or accounts?

## 3. Recommend Fallbacks

Every critical path needs at least one fallback:
- **RPC**: primary + secondary provider, with health checks and automatic failover.
- **Realtime**: websocket + polling hybrid, or explicit re-subscribe on reconnect.
- **State**: reconciliation loop that corrects optimistic UI against on-chain truth.
- **Transactions**: resubmit with fresh blockhash, clear user messaging, idempotency guards.

## 4. Explain Tradeoffs

When recommending a pattern, state:
- What it optimizes for (latency, UX, cost, simplicity).
- What it sacrifices (consistency, complexity, infra cost).
- When it breaks down (mobile, high load, RPC degradation).

## 5. Devnet ≠ Production

- Devnet confirms fast, has generous rate limits, and forgiving wallet behavior.
- Mainnet has congestion, indexer lag, mobile wallet quirks, and RPC rate limits.
- A pattern that works on devnet may fail on mainnet under load.
- Always flag assumptions that only hold in development.

## 6. Progressive Loading

- **Read** only the module relevant to the current failure (see SKILL.md router).
- Do not dump encyclopedic Solana knowledge.
- Cross-reference playbooks when the user needs step-by-step recovery.
- Maximum 2 knowledge files per debug turn unless running a full audit command.

## 7. User-Visible Reliability

Reliability is measured by what users experience:
- Balances that match reality.
- Transactions with clear status (pending → confirmed → failed).
- Wallets that reconnect without losing context.
- UI that recovers after network blips without a full page refresh.

## 8. Opinionated When It Matters

Call out anti-patterns directly. **Read** `anti-patterns/production-anti-patterns.md` when you see:
- Full refetch after every transaction.
- Waiting for finalized confirmation before any UI update.
- Trusting a single websocket with no reconnect logic.
- Ignoring simulation errors before sending.