# Transaction Failures

How transactions break in production and how to recover.

---

## Problem: Expired Blockhash

### Symptoms
- Error: `Blockhash not found` or `Transaction expired`.
- Tx sent but never lands; explorer shows nothing.
- Intermittent — worse during network congestion.

### Root Cause
Blockhashes are valid ~60–90 seconds. Slow user approval, network latency, or queueing causes the tx to arrive with a stale hash.

### Diagnosis
1. Measure time from blockhash fetch → user sign → send.
2. Check if blockhash is fetched once and reused across retries.
3. Review logs for round-trip time during peak hours.

### Recovery
- Fetch fresh blockhash immediately before `sendRawTransaction`.
- Rebuild transaction with new blockhash; ask user to re-sign only if contents changed.
- Use `lastValidBlockHeight` + `confirmTransaction` with timeout awareness.

### Prevention
- Fetch blockhash as late as possible in the pipeline.
- Show countdown or "transaction may expire" if user hesitates >30s.
- Implement automatic rebuild+resign flow for expired drafts.

---

## Problem: Simulation Failure

### Symptoms
- Wallet shows generic "Transaction failed" with no detail.
- `simulateTransaction` returns `err` before send.
- Works in dev; fails on mainnet with real accounts.

### Root Cause
On-chain program rejected the instruction: insufficient funds, wrong account owner, slippage exceeded, account frozen, or compute exceeded.

### Diagnosis
1. Always run `simulateTransaction` with `sigVerify: false` before prompting user.
2. Parse program logs from simulation — map to human-readable errors.
3. Compare account metas against program IDL expectations.
4. Check SOL balance for rent + fees; token account existence.

### Recovery
- Surface simulation logs in UI ("Insufficient SOL for rent").
- Offer fix actions: add SOL, create ATA, reduce amount.
- Never send a tx that failed simulation unless intentionally probing.

### Prevention
- Pre-flight checks: balance, ATA existence, slippage bounds.
- Map common program error codes to user-facing messages.
- Log full simulation response server-side for support.

---

## Problem: User Rejection

### Symptoms
- Tx status stuck at "pending" or silently cleared.
- No error shown; user thinks app is broken.

### Root Cause
User declined in wallet popup. App did not handle `WalletSignTransactionError` or equivalent.

### Diagnosis
1. Catch and classify wallet errors: rejection vs timeout vs network.
2. Confirm error handler runs on all sign/send code paths.

### Recovery
- Show clear message: "Transaction cancelled — no funds were moved."
- Preserve form state so user can retry without re-entering.
- Do not decrement optimistic balances on rejection.

### Prevention
- Distinct UI states: `idle`, `awaiting_signature`, `sending`, `confirming`, `confirmed`, `failed`, `rejected`.
- Never treat rejection the same as on-chain failure.

---

## Problem: Duplicate Submissions

### Symptoms
- User charged twice for same action.
- Duplicate NFT mints or duplicate orders.
- Double-click on Confirm caused two signatures.

### Root Cause
No idempotency guard; button not disabled during in-flight tx; retry logic resubmits same signed tx and user signs again.

### Diagnosis
1. Audit all submit handlers for debounce/disable logic.
2. Check if retry creates a *new* tx or resends the *same* signed bytes.
3. Look for race: two components triggering send for same action.

### Recovery
- Halt further submissions; check chain for both signatures.
- If duplicate confirmed, initiate support/refund flow per product policy.
- Document incident — add idempotency key to prevent recurrence.

### Prevention
- Disable submit button from first click until terminal state.
- Use client-generated idempotency key stored until confirmation.
- Resubmitting same signed tx is safe; re-signing is not — educate the team.

---

## Problem: Compute Budget Exceeded

### Symptoms
- `Computational budget exceeded` in logs.
- Complex DeFi routes fail intermittently.
- Works with priority fee sometimes, fails other times.

### Root Cause
Transaction exceeded default 200k CU limit. Congestion makes execution less predictable.

### Diagnosis
1. Read `unitsConsumed` from simulation.
2. Compare against set compute unit limit instruction.
3. Profile which instructions consume most CU.

### Recovery
- Add `SetComputeUnitLimit` with 10–20% headroom above simulation max.
- Simplify route or split into multiple transactions.
- Increase priority fee only after CU limit is adequate.

### Prevention
- Always simulate and set CU limit in production paths.
- Monitor CU usage percentiles per instruction type.
- Test under mainnet congestion, not just devnet.

---

## Problem: Confirmation Inconsistency

### Symptoms
- UI shows success but tx failed on-chain.
- UI shows pending forever; tx actually confirmed.
- Different pages show different tx status.

### Root Cause
Mixed confirmation strategies: some code uses `confirmed`, some `finalized`; polling stopped early; websocket missed notification.

### Diagnosis
1. Map every confirmation call site — which commitment level?
2. Check if success UI triggers on `processed` (too early) or only `confirmed`.
3. Verify signature subscription and polling both handled.

### Recovery
- Reconcile against `getSignatureStatuses` for disputed txs.
- Backfill status from explorer/RPC for stuck UI.
- Correct optimistic state to match on-chain outcome.

### Prevention
- Standard: UI success at `confirmed`; high-value settlements at `finalized`.
- Single tx status service used by all components.
- Timeout → show "still confirming" with link to explorer, not false failure.
- See `playbooks/tx-stuck.md` for full workflow.