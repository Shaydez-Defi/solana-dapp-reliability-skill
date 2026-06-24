# solana-dapp-reliability-skill

# Production Reliability Engineering for Solana dApps

**A five-layer reliability framework AI agents apply to diagnose failures, score readiness, and implement prevention patterns.**

Most Solana skills teach how to build. Official kits cover wallets, transactions, testing, security, and @solana/kit. **None own production failure recovery and reliability engineering.**

This skill fills that gap.

> **This is NOT** a Solana tutorial or frontend troubleshooting guide.  
> **This IS** The Reliability Framework — failures teach diagnosis, patterns teach prevention.

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

- Diagnoses wallet, transaction, state sync, realtime, and RPC failures
- Provides step-by-step playbooks for the most common production incidents
- Audits codebases with a Reliability Score Framework
- Guides web3.js → @solana/kit migration without big-bang rewrites
- Calls out production anti-patterns with opinionated alternatives

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
git clone https://github.com/shaydez-defi/solana-dapp-reliability-skill.git
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
> "User swapped USDC but balance didn't update for 2 minutes."

**Audit before mainnet launch:**
> `/reliability-audit` — score wallet, tx, state, realtime, RPC, and recovery.

**Fix websocket silence:**
> "Realtime prices stopped updating but no error in the UI."

**Plan a Kit migration:**
> `/migrate-to-kit` — phased migration from web3.js without breaking production.

---

## Commands

| Command | Purpose |
|---------|---------|
| `/reliability-audit` | Full codebase reliability review with scores |
| `/tx-flow-audit` | End-to-end transaction pipeline inspection |
| `/frontend-health-check` | Architecture strengths, weaknesses, concerns |
| `/migrate-to-kit` | web3.js → @solana/kit migration analysis |

---

## Reliability Score Example

See `skill/audits/reliability-score.md` for full methodology.

```
Wallet Reliability:          84/100
Transaction Reliability:     72/100
State Reliability:           58/100
Realtime Reliability:        67/100
Infrastructure Reliability:  91/100
────────────────────────────────────
Overall Reliability:         74/100
Mainnet Readiness:           28/35 checklist items — Soft launch OK
```

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
└── skill/                          # Skill root — all paths in SKILL.md are relative here
    ├── SKILL.md                    # Framework router
    ├── framework/
    │   └── reliability-framework.md
    ├── patterns/
    │   ├── optimistic-ui.md
    │   ├── reconciliation-patterns.md
    │   ├── hybrid-subscriptions.md
    │   ├── rpc-failover.md
    │   └── transaction-recovery.md
    ├── reliability/
    │   ├── wallet-failures.md
    │   ├── transaction-failures.md
    │   ├── state-sync-failures.md
    │   ├── realtime-failures.md
    │   └── rpc-failures.md
    ├── playbooks/
    │   ├── stale-balances.md
    │   ├── tx-stuck.md
    │   ├── websocket-failure.md
    │   ├── wallet-reconnect.md
    │   └── rpc-outage.md
    ├── migration/
    │   └── kit-migration.md
    ├── anti-patterns/
    │   └── production-anti-patterns.md
    ├── audits/
    │   ├── reliability-score.md
    │   ├── production-readiness-checklist.md
    │   └── reliability-checklist.md
    ├── commands/
    │   ├── reliability-audit.md
    │   ├── tx-flow-audit.md
    │   ├── frontend-health-check.md
    │   └── migrate-to-kit.md
    └── rules/
        └── reliability-rules.md
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

- New failure modes with Problem → Symptoms → Diagnosis → Fix → Prevention structure
- Additional playbooks for common incidents
- Mainnet-tested patterns (not devnet-only assumptions)

Open a PR with a clear description of the failure scenario and production evidence.

---

## License

MIT — see [LICENSE](LICENSE).

---

Built by [Shaydez-Defi](https://github.com/shaydez-defi) for Solana builders who ship to production, not just devnet.

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