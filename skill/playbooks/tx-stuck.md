# Playbook: Transaction Stuck

**User report:** "My transaction is frozen" / spinner never stops.

---

## Investigation

1. **Get the signature** (or determine tx was never sent)
   - If user signed: check wallet activity / app logs for signature.
   - If no signature: tx may have failed before `sendRawTransaction` — check wallet errors.

2. **Check on-chain status**
   ```
   getSignatureStatuses([signature])
   ```
   - `null` → not landed yet (dropped, never submitted, or still propagating).
   - `err` → failed on-chain; UI should show failure, not pending.
   - `confirmationStatus: confirmed` → success; UI bug.

3. **Check explorer**
   - Solscan / SolanaFM: landed, failed, or not found?
   - Not found after 2+ minutes on mainnet → likely dropped.

4. **Common stuck causes**
   - Waiting for `finalized` when `confirmed` is enough.
   - Websocket confirmation listener died; polling never started.
   - No timeout — pending state forever.
   - Expired blockhash: sent but never included.

---

## Recovery Workflow

### If tx failed on-chain
1. Update UI to failed with explorer link and error reason.
2. Roll back any optimistic state.
3. Offer retry with fresh blockhash.

### If tx confirmed but UI stuck
1. Force status update from `getSignatureStatuses`.
2. Fix confirmation listener / polling bug.
3. Invalidate dependent state (balances, positions).

### If tx not found (dropped)
1. After 60–90s, show: "Transaction not confirmed. It may have been dropped."
2. Options: **Check explorer** | **Retry** (new blockhash, new sign if needed).
3. Do not resubmit same tx if user may have already signed a replacement.

### If network congested
1. Show honest status: "Network busy — confirmation may take longer."
2. Link to explorer; keep polling with backoff.
3. Suggest priority fee on retry if appropriate.

---

## Prevention

- **Timeout policy:** pending > 90s → "still confirming" UI with explorer link; > 5min → suggest retry.
- **Commitment standard:** UI success at `confirmed`; reserve `finalized` for high-value settlement only.
- **Single tx status service** shared by all components.
- **Always parse** `getSignatureStatuses` errors — never infinite spinner.
- **Log:** signature, send time, confirmation time, commitment level, provider used.

---

## Related Modules

- `skill/reliability/transaction-failures.md`
- `skill/reliability/rpc-failures.md` (if RPC can't return status)