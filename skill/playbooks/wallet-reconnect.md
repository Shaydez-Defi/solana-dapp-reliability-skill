# Playbook: Wallet Reconnect

**User report:** "Wallet keeps disconnecting" / "Can't connect my wallet."

**Severity:** Critical  
**Frequency:** Common  
**User Impact:** Critical — blocks all on-chain actions until resolved.

---

## Investigation

1. **Classify the pattern**
   - Reconnect loop (connect → disconnect → connect)?
   - One-time failure after working before?
   - Mobile-only or desktop-only?
   - Specific wallet (Phantom, Backpack, WalletConnect)?

2. **Check adapter events**
   - Log: `connect`, `disconnect`, `accountChanged`, `error` with timestamps.
   - Who calls `connect()`? How many times per user action?

3. **Check provider tree**
   - Single `WalletProvider` at root?
   - Remounting on route change?
   - Multiple adapter instances?

4. **Check network alignment**
   - App `cluster` vs wallet selected network.
   - Custom RPC endpoint breaking wallet validation?

5. **Mobile-specific**
   - In-app browser? Deep-link return path?
   - WalletConnect session expired?

---

## Recovery

| Pattern | Fix |
|---------|-----|
| Reconnect loop | Guard `connect()`; fix duplicate triggers; check network mismatch |
| Stale session | `disconnect()` → clear caches → manual reconnect |
| Mobile deep-link fail | Prompt "Open in Safari"; try QR / WalletConnect |
| Wrong network | Show explicit "Switch to Mainnet" UI; don't silently retry |
| Extension locked | Detect and prompt "Unlock your wallet" |

**User unblock:** "Disconnect wallet" button that fully resets adapter state + clears app caches.

---

## Mobile Edge Cases

- Safari ITP blocking storage → graceful reconnect, don't assume persistence.
- Wallet app switch losing callback → persist WalletConnect session.
- Twitter/Discord in-app browser → detect and redirect to system browser.
- Page reload during connect → restore in-flight WalletConnect session.

---

## Prevention

- Wallet state machine: `disconnected → connecting → connected → reconnecting`.
- One connect entry point; cap auto-reconnect attempts.
- Clear all wallet-scoped caches on `accountChanged` and `disconnect`.
- Test matrix: Phantom + Backpack + WalletConnect × iOS + Android + desktop.

---

## Related Modules

- `reliability/wallet-failures.md`