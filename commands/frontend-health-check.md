# Command: /frontend-health-check

Review frontend architecture for reliability strengths and weaknesses.

---

## When to Run

User asks about frontend architecture, data flow, or general dApp health — broader than tx-only audit.

## Steps

1. Read `rules/reliability-rules.md`.
2. Load modules as needed based on what you find:
   - `skill/reliability/state-sync-failures.md`
   - `skill/reliability/wallet-failures.md`
   - `skill/reliability/realtime-failures.md`
   - `skill/anti-patterns/production-anti-patterns.md`

3. Review architecture layers:

   | Layer | Check |
   |-------|-------|
   | Wallet | Provider placement, event handling, mobile |
   | Data | Single source of truth? Cache library? Key conventions? |
   | RPC | Client abstraction? Failover? Coalescing? |
   | Realtime | Subscription manager? Cleanup? Fallback? |
   | Tx | Centralized pipeline or scattered sends? |
   | UI states | Loading, error, degraded, empty — all covered? |
   | Error UX | Actionable messages? Explorer links? Recovery paths? |

4. Return structured assessment:

## Output Format

```markdown
## Frontend Health Check

### Strengths
- ...

### Weaknesses
- ...

### Reliability Concerns (ranked)
1. ...

### Architecture diagram (current vs recommended)
[brief description or mermaid if helpful]

### Next steps
- Quick fixes: ...
- Structural improvements: ...
```

## Rules

- Focus on reliability, not aesthetics or code style.
- Note when devnet assumptions are baked into architecture.
- Recommend hybrid patterns (websocket + reconcile) where realtime exists.