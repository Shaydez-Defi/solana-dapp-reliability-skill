# Pattern: Hybrid Subscriptions

**Layer 4 — Realtime Reliability**

Websocket for speed. RPC for truth. Never trust one transport alone.

---

## Architecture

```
┌──────────────┐     deltas      ┌──────────────┐
│  WebSocket   │ ──────────────▶ │   UI State   │
│  subscriptions│                │              │
└──────────────┘                 └──────▲───────┘
       │                                │
       │ heartbeat                      │ reconcile
       ▼                                │
┌──────────────┐     snapshot    ┌──────┴───────┐
│  Reconnect   │ ──────────────▶ │  RPC Poll    │
│  coordinator │                 │  (15–30s)    │
└──────────────┘                 └──────────────┘
```

---

## Production Rules

1. **Primary:** websocket `accountSubscribe` / program subscriptions for watched accounts.
2. **Heartbeat:** no message in 30–60s → force reconnect with backoff.
3. **On reconnect:** RPC snapshot all critical accounts before resuming stream.
4. **Reconcile:** periodic RPC diff every 15–30s regardless of websocket health.
5. **Fallback:** websocket unhealthy >60s → switch to polling until recovered.
6. **UX:** show connection health when degraded — never silent failure.

---

## Subscription Manager

Centralize all subscriptions:

- One listener per account (reference counted)
- `subscribe(pubkey)` / `unsubscribe(pubkey)` API
- Ban raw `onAccountChange` in leaf components
- Cleanup on unmount — always

---

## Transport Selection

| Data type | Primary | Fallback |
|-----------|---------|----------|
| Active trading positions | WebSocket | 5s RPC poll |
| User wallet balances | WebSocket + reconcile | 15s RPC poll |
| Historical NFT gallery | Indexer HTTP | RPC on miss |
| Tx confirmation | `signatureSubscribe` + status poll | `getSignatureStatuses` |

---

## Related

- Failures: `reliability/realtime-failures.md`
- Playbook: `playbooks/websocket-failure.md`
- Pattern: `patterns/reconciliation-patterns.md`