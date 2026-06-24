# Hackathon Submission — Solana dApp Reliability Skill

**Bounty:** [Ship useful agent skills we can add to Solana AI Kit](https://superteam.fun/earn/listing/skills/) by Superteam Brasil

**Repo:** https://github.com/Shaydez-Defi/solana-dapp-reliability-skill

**Author:** Shaydez-Defi

---

## One-Line Pitch

Teach AI coding agents how to diagnose, prevent, and recover from the failures that make Solana dApps feel broken in production.

---

## Why This Skill Should Be Added to Solana AI Kit

Solana AI Kit ships 18+ skills for **building** — Anchor, DeFi integrations, mobile, security. None focus on **production reliability** for frontend dApps.

Every team using the kit will eventually hit:
- Stale balances after transactions
- Wallet reconnect loops on mobile
- Websocket data freezing silently
- RPC 429s during congestion
- Transaction spinners that never resolve

This skill fills a gap the kit's `solana-dev` and `sendai` skills don't cover: **how things break after you ship**.

---

## What Makes It Different

| Most Solana skills | This skill |
|--------------------|------------|
| How to connect a wallet | Why wallet UX fails in production |
| How to send a transaction | Why txs get stuck and how to recover |
| How to read accounts | Why UI state drifts from on-chain truth |
| Framework tutorials | Failure-mode playbooks |

**Organized around failures, not frameworks.**

---

## Solana AI Kit Architecture Fit

| AI Kit pattern | This repo |
|----------------|-----------|
| `skill/SKILL.md` router | ✅ Progressive loading — never dumps all knowledge |
| `commands/` | ✅ 4 audit commands |
| `rules/` | ✅ `reliability-rules.md` |
| `install.sh` | ✅ Project, global, Cursor, Claude scopes |
| `validate.sh` | ✅ Structure integrity checks |
| `ext/` submodule install | ✅ See `docs/AI-KIT-INTEGRATION.md` |

---

## Demo — See It Work

**Live audit example:** [`examples/demo-audit.md`](examples/demo-audit.md)

Audited the official Solana Foundation counter template. Found:
- Empty wallet adapter list (critical)
- Silent transaction error swallowing (critical)
- No simulation, no failover RPC, no realtime subscriptions
- Overall score: **52/100 — not production-ready**

This is exactly what hackathon teams fork and ship broken.

---

## Install & Try

```bash
git clone https://github.com/Shaydez-Defi/solana-dapp-reliability-skill.git
cd solana-dapp-reliability-skill
chmod +x install.sh validate.sh
./validate.sh          # verify structure
./install.sh --global  # install skill
```

### Example prompts

```
/reliability-audit
My user's balance didn't update after a swap — help me debug.
/reliability-audit on my codebase before mainnet launch
/tx-flow-audit
/frontend-health-check
/migrate-to-kit
```

---

## Commands

| Command | What it does |
|---------|--------------|
| `/reliability-audit` | Full codebase review with 6-category reliability score |
| `/tx-flow-audit` | End-to-end transaction pipeline inspection |
| `/frontend-health-check` | Architecture strengths, weaknesses, concerns |
| `/migrate-to-kit` | web3.js → @solana/kit phased migration guidance |

---

## Repository Stats

- **21 knowledge files** across 5 reliability modules, 5 playbooks, migration, anti-patterns
- **Reliability Score Framework** with 6 weighted categories
- **10 production anti-patterns** with alternatives
- **MIT licensed** — ready for AI Kit `ext/` submodule

---

## Suggested AI Kit Integration

Add as external skill submodule:

```bash
git submodule add https://github.com/Shaydez-Defi/solana-dapp-reliability-skill.git \
  .claude/skills/ext/solana-dapp-reliability
```

Or register in `skill-registry.json`:

```json
{
  "id": "solana-dapp-reliability",
  "name": "Solana dApp Reliability",
  "type": "skill",
  "domain": "solana-frontend",
  "description": "Production reliability for Solana dApps — diagnose stale balances, wallet failures, RPC outages, websocket drops, and tx confirmation issues.",
  "source": "https://github.com/Shaydez-Defi/solana-dapp-reliability-skill",
  "install": {
    "method": "submodule",
    "command": "git submodule add https://github.com/Shaydez-Defi/solana-dapp-reliability-skill.git .claude/skills/ext/solana-dapp-reliability",
    "env": []
  },
  "license": "MIT",
  "maintainer": "Shaydez-Defi",
  "tags": ["reliability", "frontend", "wallet", "rpc", "websocket", "production", "audit"]
}
```

Full integration guide: [`docs/AI-KIT-INTEGRATION.md`](docs/AI-KIT-INTEGRATION.md)

---

## Contact

- **GitHub:** https://github.com/Shaydez-Defi
- **Repo issues:** https://github.com/Shaydez-Defi/solana-dapp-reliability-skill/issues