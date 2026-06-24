# Command: /migrate-to-kit

Analyze legacy web3.js patterns and provide @solana/kit migration guidance.

---

## When to Run

User asks about migrating to @solana/kit, modernizing Solana client code, or replacing web3.js.

## Steps

1. **Read** `migration/kit-migration.md`.
2. Scan codebase for web3.js usage:
   - `import { Connection, PublicKey, Transaction } from '@solana/web3.js'`
   - `connection.get*`, `connection.send*`, `connection.on*`
   - Manual buffer decoding
   - Wallet adapter + web3.js transaction building

3. Categorize findings:

   | Area | Files | Migration complexity | Reliability risk if rushed |
   |------|-------|---------------------|---------------------------|
   | RPC reads | | Low/Med/High | |
   | Tx pipeline | | | |
   | Subscriptions | | | |
   | Account decode | | | |

4. Recommend phased migration order (from kit-migration.md):
   - Phase 1: compatibility layer
   - Phase 2: RPC → tx → accounts → subscriptions
   - Phase 3: remove web3.js

5. Flag blockers:
   - No simulation in current tx path → fix before migrating
   - No test coverage → add mainnet smoke tests first
   - Tight wallet adapter coupling → plan signer abstraction

## Output Format

```markdown
## Kit Migration Analysis

### Current web3.js surface area
- [count] files, [count] Connection call sites

### Recommended migration order
1. ...

### Per-module guidance
| Module | Current pattern | Kit target | Notes |
|--------|----------------|------------|-------|

### Risks if migrating now
- ...

### Prerequisites (fix first)
- ...

### Estimated effort
- Phase 1: ...
- Phase 2: ...
```

## Rules

- Do not recommend big-bang rewrite.
- Tie migration steps to reliability improvements, not just API fashion.
- If app has active production incidents, fix those patterns in web3.js first.