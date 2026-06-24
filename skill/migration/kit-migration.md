# Kit Migration: web3.js → @solana/kit

Real migration scenarios, not theory. Focus on reliability improvements gained (and risks introduced) by migrating.

---

## Why Migrate

| web3.js pain | @solana/kit benefit |
|--------------|---------------------|
| Monolithic `Connection` API | Composable RPC subscriptions and typed clients |
| Manual transaction building | `TransactionSigner` abstractions, cleaner signing flows |
| Scattered account decoding | Typed codecs, consistent serialization |
| Implicit error handling | Explicit result types, easier to build retry logic |

**Reliability win:** Kit encourages explicit, typed pipelines — easier to add simulation, retry, and reconciliation at each step.

---

## Migration Strategy (Recommended)

### Phase 1: Compatibility Layer
- Keep web3.js for stable paths.
- Introduce Kit for **new** code paths (one feature at a time).
- Shared types at boundaries: `PublicKey` → `Address`, tx bytes format.

### Phase 2: Critical Path Migration
Migrate in this order (highest reliability impact first):
1. **RPC client** — health checks, failover, typed requests.
2. **Transaction pipeline** — build → simulate → sign → send → confirm.
3. **Account fetching** — replace `getAccountInfo` + manual decode.
4. **Subscriptions** — websocket account watches.

### Phase 3: Remove web3.js
- Only when all paths migrated and tested on mainnet.
- Pin Kit version; run regression suite.

---

## Common Mistakes

### 1. Big-Bang Rewrite
**Symptom:** Month-long branch; endless merge conflicts; reliability regressions at launch.
**Fix:** Strangler fig — one module per sprint.

### 2. Mixing Types at Boundaries
**Symptom:** `PublicKey` vs `Address` mismatches; silent wrong-account bugs.
**Fix:** Conversion helpers at module boundaries only; never pass raw strings.

### 3. Dropping Simulation on Migrate
**Symptom:** Kit send path works on devnet; mainnet failures surprise users.
**Fix:** Port simulation step explicitly; map Kit errors to user messages.

### 4. Ignoring Signer Abstraction
**Symptom:** Wallet adapter integration breaks; mobile signing fails.
**Fix:** Implement `TransactionSigner` for wallet adapter early; test Phantom + mobile.

### 5. Subscription API Differences
**Symptom:** Realtime data stops after migration.
**Fix:** Rebuild subscription manager against Kit RPC subscriptions; run websocket playbook tests.

---

## Architecture Changes

### Before (web3.js)
```
Component → Connection.getX() → manual decode → local state
Component → buildTx() → wallet.sign → sendRawTransaction → poll confirm
```

### After (@solana/kit)
```
Component → typed RPC client → codec decode → unified cache
Component → tx pipeline (simulate → sign → send → confirm) → event bus → cache invalidation
```

**Key reliability addition:** Event bus broadcasts tx lifecycle → all caches invalidate consistently.

---

## Transaction Pattern Migration

### web3.js pattern
```typescript
const { blockhash } = await connection.getLatestBlockhash();
tx.recentBlockhash = blockhash;
const signed = await wallet.signTransaction(tx);
const sig = await connection.sendRawTransaction(signed.serialize());
await connection.confirmTransaction(sig, 'confirmed');
```

### Kit-oriented pattern (conceptual)
1. Fetch blockhash via typed RPC — as late as possible.
2. Build instruction list with typed program clients.
3. Simulate — parse errors before wallet prompt.
4. Sign via `TransactionSigner` (wallet adapter backed).
5. Send with retry on blockhash expiry only (not blind resend).
6. Confirm at `confirmed`; reconcile state; rollback optimistic on failure.

---

## Account Fetching Migration

### web3.js
- `getAccountInfo` + manual buffer offset parsing.
- Easy to drift from program updates.

### Kit
- Program-derived codecs decode accounts consistently.
- Version codec with program IDL releases.

**Reliability win:** Decode errors surface at development time, not as wrong balances in production.

---

## Testing Migration

- [ ] Mainnet read: balances match web3.js path for same accounts.
- [ ] Send + confirm: success, rejection, expired blockhash, simulation failure.
- [ ] Websocket: account updates arrive after Kit subscription migration.
- [ ] Mobile wallet signing through Kit signer abstraction.
- [ ] RPC failover still works with Kit client wrapper.

---

## When NOT to Migrate Yet

- Hackathon deadline < 1 week away.
- No mainnet test coverage for current web3.js paths.
- Team has no Kit experience and no reliability baseline to compare against.

Fix reliability patterns in web3.js first (this skill's modules apply regardless of library). Migrate when you can A/B test on mainnet.