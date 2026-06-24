# solana-dapp-reliability-skill

This skill teaches AI agents how to **diagnose, prevent, and recover** from the failures that make Solana dApps unreliable in production.

The official Solana dev skill teaches how to build. **This skill teaches how to survive reality.**

> **Not:** how to build a Solana dApp (wallets, txs, React, @solana/kit — official skill owns that)  
> **Yes:** diagnose and recover from production failures using **The DApp Reliability Framework**

## The Reliability Framework

| Layer | Focus |
|-------|-------|
| 1 — Wallet | Connect, sign, reconnect, mobile |
| 2 — Transaction | Simulate, send, confirm, recover |
| 3 — State | Balances, optimistic UI, reconciliation |
| 4 — Realtime | Websockets, subscriptions, hybrid fallback |
| 5 — Infrastructure | RPC failover, rate limits, health |

---

## What It Does

- **5-layer Reliability Framework** — classify any production issue
- **Reliability Score** — weighted 0–100 output judges can point at
- **5 battle-tested playbooks** — stale balance, stuck tx, can't sign, websocket, RPC outage
- **Production Readiness Checklist** — 10-item founder-friendly mainnet gate
- Failure modules for deep diagnosis (wallet, tx, state, realtime, infrastructure)

---

## Why It Exists

Builders repeatedly hit the same problems:

| Symptom | Category |
|---------|----------|
| Stale balances after swap | State sync |
| Wallet reconnect loops | Wallet |
| Mobile wallet won't connect | Wallet |
| Data frozen, no error shown | Realtime |
| RPC 429 / outage | RPC |
| Tx spinner never stops | Transaction |
| UI shows success, tx failed | State sync |

Developers stop at *"the feature works."* Production teams ask *"what happens when it breaks?"*

---

## Installation

### Quick install (project-scoped)

```bash
git clone https://github.com/Shaydez-Defi/solana-dapp-reliability-skill.git
cd solana-dapp-reliability-skill
chmod +x install.sh
./install.sh
```

### Global install (all projects)

```bash
./install.sh --global
```

### Cursor / Claude Code compatibility

```bash
./install.sh --global --cursor --claude
```

### Manual install

Copy `skill/` contents to your agent skills directory:

```
~/.grok/skills/solana-dapp-reliability/SKILL.md
```

Or for project scope:

```
your-dapp/.grok/skills/solana-dapp-reliability/SKILL.md
```

---

## Example Use Cases

**Debug a stale balance:**
> "User swapped USDC but balance didn't update for 2 minutes." → `playbooks/stale-balances.md`

**Audit before mainnet launch:**
> `/reliability-audit` — five-layer scores + overall score + 10-item checklist.

**Trace silent tx failures:**
> `/tx-flow-audit` — button click → confirm → UI update.

**Architecture survivability review:**
> `/frontend-health-check` — strengths, weaknesses, layer scores.

**Fix websocket silence:**
> "Realtime prices stopped updating but no error in the UI." → `playbooks/websocket-failure.md`

**Plan a Kit migration:**
> `/migrate-to-kit` — phased web3.js → @solana/kit without breaking production.

---

## Commands

| Command | Purpose |
|---------|---------|
| `/reliability-audit` | 5-layer score + checklist + verdict |
| `/tx-flow-audit` | Trace tx pipeline for silent failures |
| `/frontend-health-check` | Architecture survivability review |
| `/migrate-to-kit` | Phased web3.js → @solana/kit migration |

---

## Reliability Score Example

See `skill/reliability-score.md` for scoring rubric.

```
Wallet Reliability:          62
Transaction Reliability:     58
State Reliability:           71
Realtime Reliability:        35
Infrastructure Reliability:  48
────────────────────────────────
Overall Score:               55

Checklist: 2/10 passed
Verdict: Not mainnet-ready
```

---

## Production Readiness Checklist

See `skill/production-readiness-checklist.md` for the full 10-item gate.

```
[ ] Wallet recovery tested
[ ] Mobile wallet tested
[ ] RPC failover configured
[ ] WebSocket recovery configured
[ ] Optimistic updates reconciled
[ ] Retry logic exists
[ ] Rate limits handled
[ ] Transaction failure UX exists
[ ] Indexer lag handled
[ ] State reconciliation implemented
```

**Verdict:** 9–10 = mainnet ready · 7–8 = soft launch · <5 = not ready

---

## Repository Structure

```
solana-dapp-reliability-skill/
├── README.md
├── LICENSE
├── install.sh
├── validate.sh
├── SUBMISSION.md
├── examples/
└── skill/
    ├── SKILL.md
    ├── reliability-framework.md          # Load first for audits
    ├── production-readiness-checklist.md # 10-item mainnet gate
    ├── reliability-score.md              # Scoring rubric + output format
    ├── reliability/
    │   ├── wallet-failures.md
    │   ├── transaction-failures.md
    │   ├── state-sync-failures.md
    │   ├── realtime-failures.md
    │   └── rpc-failures.md
    ├── playbooks/                        # First-class — load before modules
    │   ├── stale-balances.md
    │   ├── tx-stuck.md
    │   ├── wallet-cannot-sign.md
    │   ├── websocket-failure.md
    │   └── rpc-outage.md
    ├── migration/
    │   └── kit-migration.md
    └── anti-patterns/
        └── production-anti-patterns.md
```

---

## Philosophy

- Organized around **failures**, not technologies
- **Progressive loading** — SKILL.md routes to one module at a time
- **Opinionated** — calls out anti-patterns directly
- **Practical** — based on real production failure modes
- **Smallest complete version** — depth over encyclopedia breadth

---

## Contributing

Contributions welcome. Focus areas:

- New failure modes with Severity / Frequency / User Impact
- Additional playbooks (Symptoms → Causes → Verification → Fixes → Prevention)
- Mainnet-tested recovery steps (not devnet-only assumptions)

Open a PR with a clear description of the failure scenario and production evidence.

---

## License

MIT — see [LICENSE](LICENSE).

---

Built by [Shaydez-Defi](https://github.com/Shaydez-Defi) for Solana builders who ship to production, not just devnet.

---

## Hackathon / Solana AI Kit

Submitted for [Superteam Brasil — Ship useful agent skills for Solana AI Kit](https://superteam.fun/earn/listing/skills/).

| Resource | Description |
|----------|-------------|
| [SUBMISSION.md](SUBMISSION.md) | Full hackathon submission pitch |
| [examples/demo-audit.md](examples/demo-audit.md) | Live audit of Solana Foundation counter template |
| [examples/demo-prompts.md](examples/demo-prompts.md) | Copy-paste prompts to demo the skill |
| [docs/AI-KIT-INTEGRATION.md](docs/AI-KIT-INTEGRATION.md) | How to add as AI Kit `ext/` submodule |

### Validate structure

```bash
chmod +x validate.sh
./validate.sh
```