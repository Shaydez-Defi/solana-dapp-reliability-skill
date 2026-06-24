# Command: /tx-flow-audit

Inspect the transaction lifecycle end-to-end.

---

## When to Run

User asks about transaction reliability, confirmation issues, or wants tx pipeline reviewed.

## Steps

1. Read `skill/reliability/transaction-failures.md`.
2. Read `skill/playbooks/tx-stuck.md`.
3. Trace the full tx flow in codebase:

   ```
   User action → build instructions → fetch blockhash → simulate →
   wallet sign → send → confirm → update UI → invalidate cache
   ```

4. Check each stage:

   | Stage | Questions |
   |-------|-----------|
   | Build | Fresh account data? Correct program accounts? CU limit set? |
   | Blockhash | Fetched late? Rebuilt on expiry? `lastValidBlockHeight` tracked? |
   | Simulate | Always run? Errors mapped to user messages? |
   | Sign | Rejection handled? Button disabled during flight? |
   | Send | Retry policy? Duplicate guard? |
   | Confirm | Which commitment? Timeout? Polling fallback? |
   | UI update | Optimistic? Reconciled? Rolled back on failure? |
   | Cache | Targeted invalidation? Correct cache keys? |

5. List failures not handled (expired blockhash, rejection, simulation fail, dropped tx, timeout).

6. Return findings with severity: **Critical** (user loses funds/trust), **High**, **Medium**, **Low**.

## Output Format

```markdown
## Transaction Flow Audit

### Flow diagram (as implemented)
[describe actual path]

### Gaps
| Stage | Issue | Severity | Fix |
|-------|-------|----------|-----|

### What's working well
- ...

### Recommended changes (priority order)
1. ...
```