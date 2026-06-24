# Playbook: Wallet Connects But User Cannot Sign

**Layer 1 — Wallet Reliability**

**Severity:** Critical | **Frequency:** Common | **User Impact:** High

---

## Symptoms

- UI shows connected address; Sign/Send does nothing or hangs
- `publicKey` set but `signTransaction` never resolves
- Works after refresh; fails after tab backgrounded (especially mobile)

## Likely Causes

- Stale adapter state after extension lock/update
- Event listeners not re-attached after disconnect cycle
- Multiple `WalletProvider` instances
- Mobile session killed silently (in-app browser, background tab)
- `publicKey` cached in React state — out of sync with adapter

## Verification Steps

1. Log adapter events: `connect`, `disconnect`, `accountChanged`, `error`
2. Does `wallet.adapter.connected` match UI?
3. Count `WalletProvider` instances — must be one at root
4. Mobile: reproduce Safari background + wallet app switch
5. Check if `signTransaction` hangs or throws (different fixes)

## Fixes

| Finding | Action |
|---------|--------|
| Stale adapter | Full disconnect → clear caches → reconnect |
| UI/cache drift | Sync UI only from adapter events; never cache pubkey alone |
| Multiple providers | Single provider above router; stabilize tree |
| Mobile session dead | Detect in-app browser; prompt open in Safari/Chrome |
| Extension locked | Detect and prompt "Unlock your wallet" |

## Prevention

- Wallet state machine: `disconnected → connecting → connected → reconnecting`
- On `accountChanged`: invalidate all wallet-scoped caches
- Test Phantom + Backpack on iOS and Android before mainnet

**Module:** `reliability/wallet-failures.md`