# Wallet Failures

**Layer 1 — Wallet Reliability**

Everything that causes wallet UX to fail in production.  
**Playbook:** `playbooks/wallet-cannot-sign.md`

Each failure includes **Severity**, **Frequency**, and **User Impact**.

---

## Problem: Wallet Shows Connected But Cannot Sign

**Severity:** Critical  
**Frequency:** Common  
**User Impact:** High — blocks all transactions; user sees connected UI but cannot sign.

### Symptoms
- UI displays connected address; sign/send buttons do nothing or hang.
- `publicKey` is set but `signTransaction` never resolves.
- Works after refresh; fails after tab backgrounded on mobile.

### Likely Causes
- Stale adapter state after wallet extension updated or locked.
- Event listener not re-attached after `disconnect`/`connect` cycle.
- Multiple adapter instances fighting over the same wallet.
- Mobile in-app browser killed the wallet session silently.

### Diagnosis
1. Log adapter events: `connect`, `disconnect`, `accountChanged`, `error`.
2. Check if `wallet.adapter.connected` matches UI state.
3. Verify only one `WalletProvider` / adapter manager exists.
4. On mobile: test Safari backgrounding, wallet app switch, and deep-link return.

### Fix
- Sync UI strictly from adapter events — never cache `publicKey` independently.
- On `accountChanged`, invalidate all wallet-dependent state and re-fetch.
- Debounce reconnect attempts; cap retry count to avoid loops.
- Use `autoConnect` with explicit timeout and fallback to manual connect.

### Prevention
- Single wallet provider at app root.
- Centralized wallet state machine: `disconnected → connecting → connected → reconnecting`.
- Persist last-used wallet name only — not session secrets.
- Test Phantom, Backpack, and WalletConnect on iOS and Android.

---

## Problem: Reconnect Loop

**Severity:** Critical  
**Frequency:** Common  
**User Impact:** High — user cannot complete any transaction; connect flow is broken.

### Symptoms
- Wallet connects, immediately disconnects, repeats indefinitely.
- Console spam: connect/disconnect events.
- User cannot complete a transaction.

### Likely Causes
- `autoConnect` firing while user manually connects.
- App re-renders remounting `WalletProvider` on every route change.
- Wallet rejecting connection because chain/network mismatch.
- Race: connect called before adapter finished initializing.

### Diagnosis
1. Add logging with timestamps on every connect/disconnect call site.
2. Search for multiple `connect()` invocations (useEffect deps, route guards).
3. Confirm `cluster` / `network` matches wallet's selected network.
4. Check if `WalletModal` or custom connect triggers duplicate calls.

### Fix
- Guard `connect()` with `if (connecting || connected) return`.
- Stabilize provider tree — wallet context above router, not inside pages.
- Align app network config with wallet; show clear mismatch UI instead of silent retry.
- Remove redundant `autoConnect` if manual flow is primary.

### Prevention
- One connect entry point (modal or button), not scattered across components.
- Integration test: connect → navigate 5 routes → still connected.
- Document supported wallets and networks in README/onboarding.

---

## Problem: Mobile Wallet Deep-Link Failures

**Severity:** High  
**Frequency:** Common (mobile)  
**User Impact:** High — blocks mobile users from connecting; desktop may work fine.

### Symptoms
- User taps Connect; wallet app opens but dApp never receives approval.
- Return from Phantom/Solflare leaves blank or stale page.
- Works on desktop extension; fails on mobile browser.

### Likely Causes
- Deep-link callback URL not registered or blocked.
- Page reload loses in-flight connection state.
- WalletConnect session expired; no refresh logic.
- In-app browser (Twitter, Discord) blocks wallet redirects.

### Diagnosis
1. Reproduce in Safari/Chrome mobile, not just desktop responsive mode.
2. Check WalletConnect `relayer` connectivity and session TTL.
3. Verify callback handling survives page visibility changes.
4. Test inside vs outside in-app browsers.

### Fix
- Detect in-app browsers; prompt "Open in Safari/Chrome".
- Persist WalletConnect session in `localStorage` with restore on load.
- Show explicit "Return to app" instruction after wallet approval.
- Fallback to QR code flow when deep-link fails.

### Prevention
- Mobile-first connect UX with status messages at every step.
- Timeout + retry with different transport (deep-link → QR).
- Monitor connect funnel: initiated → wallet opened → approved → connected.

---

## Problem: Multi-Wallet Conflicts

**Severity:** High  
**Frequency:** Occasional  
**User Impact:** High — wrong signer or stale balances; can cause failed txs or user distrust.

### Symptoms
- Wrong wallet signs the transaction.
- Balance from wallet A shown while wallet B is "connected".
- Switching wallets leaves stale token accounts in UI.

### Likely Causes
- Global state not cleared on `accountChanged` or wallet switch.
- Cached RPC queries keyed without wallet pubkey.
- Multiple wallets installed; adapter picks wrong default.

### Diagnosis
1. Trace state keys — are queries scoped to `publicKey.toBase58()`?
2. Confirm `disconnect` clears React Query / SWR / Zustand caches.
3. Log which adapter instance handles each sign request.

### Fix
- On wallet change: `queryClient.clear()` or invalidate all wallet-scoped keys.
- Namespace all caches: `['balance', pubkey]`, `['positions', pubkey]`.
- Reset transaction drafts and pending UI on account switch.

### Prevention
- Treat wallet pubkey as part of every data identity.
- Never store unsigned transactions across wallet switches.
- E2E test: connect wallet A → view data → switch to B → no bleed-through.

---

## Problem: Session Persistence Across Refresh

**Severity:** Medium  
**Frequency:** Common  
**User Impact:** Medium — annoying reconnect friction; does not block txs once connected.

### Symptoms
- User must reconnect on every page load.
- `autoConnect` works locally but not in production.
- Session lost after deploy or CDN cache bust.

### Likely Causes
- `localStorage` blocked (Safari ITP, private mode).
- `autoConnect` disabled in production build.
- Wallet adapter version mismatch after dependency update.

### Diagnosis
1. Check `localStorage` for wallet name key (adapter-specific).
2. Compare dev vs prod `WalletProvider` config.
3. Verify CSP headers don't block wallet iframe/popup.

### Fix
- Graceful degradation: remember last wallet, offer one-click reconnect.
- Store only wallet name, never private keys or session tokens in custom storage.
- Pin and test adapter versions across releases.

### Prevention
- Document expected reconnect behavior per wallet.
- Track `wallet_reconnect_success` metric in analytics.