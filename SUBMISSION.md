# Hackathon Submission — Solana dApp Reliability Skill

**Bounty:** [Ship useful agent skills we can add to Solana AI Kit](https://superteam.fun/earn/listing/skills/) by Superteam Brasil

**Repo:** https://github.com/Shaydez-Defi/solana-dapp-reliability-skill

**Author:** Shaydez-Defi

---

## One-Line Pitch

This skill teaches AI agents how to **diagnose, prevent, and recover** from the failures that make Solana dApps unreliable in production.

---

## Why This Skill Should Be Added to Solana AI Kit

Solana AI Kit ships 18+ skills for **building** — wallets, transactions, testing, security, @solana/kit. Protocol skills cover DeFi integrations. **No skill owns production failure diagnosis and recovery.**

This is not "better frontend patterns." It is **The DApp Reliability Framework** — a five-layer methodology judges can remember.

Every team using the kit will eventually hit:
- Stale balances after transactions
- Wallet connected but can't sign
- Websocket data freezing silently
- RPC 429s during congestion
- Transaction spinners that never resolve

This skill fills a gap the kit's `solana-dev` skill doesn't cover: **how things break after you ship**.

---

## The DApp Reliability Framework

| Layer | What it covers |
|-------|----------------|
| 1 — Wallet Reliability | Connect, sign, reconnect, mobile |
| 2 — Transaction Reliability | Simulate, send, confirm, recover |
| 3 — State Reliability | Stale balances, optimistic UI, reconciliation |
| 4 — Realtime Reliability | Websockets, subscriptions, hybrid fallback |
| 5 — Infrastructure Reliability | RPC failover, rate limits, health |

**Playbooks** (`playbooks/`) are first-class — step-by-step recovery for the five most common production incidents.  
**Failure modules** (`reliability/`) provide deep diagnosis with Severity / Frequency / User Impact.  
**Production Readiness Checklist** — 10-item founder-friendly mainnet gate.  
**Reliability Score** — weighted 0–100 output artifact every audit produces.

---

## What Makes It Different

| Official Solana dev skill | This skill |
|---------------------------|------------|
| How to build dApps | How to survive production |
| Wallet connect, tx build, React patterns | Diagnose and recover from failures |
| Tutorial content | Framework + playbooks + checklist |

**Organized around failures, not technologies.**

---

## Solana AI Kit Architecture Fit

| AI Kit pattern | This repo |
|----------------|-----------|
| `skill/SKILL.md` router | ✅ Progressive loading — max 2–3 files per turn |
| `reliability-framework.md` at skill root | ✅ Load first for audits |
| `production-readiness-checklist.md` | ✅ 10-item mainnet gate |
| `reliability-score.md` | ✅ Weighted scoring rubric + output format |
| `install.sh` | ✅ Project, global, Cursor, Claude scopes |
| `validate.sh` | ✅ Structure integrity + scope trim checks |
| `ext/` submodule install | ✅ See `docs/AI-KIT-INTEGRATION.md` |

---

## Demo — See It Work

**Live audit example:** [`examples/demo-audit.md`](examples/demo-audit.md)

Audited the official Solana Foundation counter template. Found:
- Empty wallet adapter list (critical)
- Silent transaction error swallowing (critical)
- No simulation, no failover RPC, no realtime subscriptions
- Overall score: **55/100** — checklist **2/10** — not production-ready

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
/tx-flow-audit
/frontend-health-check
/migrate-to-kit
My user's balance didn't update after a swap — help me debug.
Wallet connected but user cannot sign.
```

---

## Repository Stats

- **15 knowledge files** — framework, score, checklist, 5 failure modules, 5 playbooks, migration, anti-patterns
- **5 battle-tested playbooks** with Symptoms → Causes → Verification → Fixes → Prevention
- **10-item production readiness checklist**
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
  "description": "Diagnose and recover from production failures in Solana dApps — stale balances, wallet issues, RPC outages, websocket drops, tx failures. Five-layer framework + playbooks + mainnet checklist.",
  "source": "https://github.com/Shaydez-Defi/solana-dapp-reliability-skill",
  "install": {
    "method": "submodule",
    "command": "git submodule add https://github.com/Shaydez-Defi/solana-dapp-reliability-skill.git .claude/skills/ext/solana-dapp-reliability",
    "env": []
  },
  "license": "MIT",
  "maintainer": "Shaydez-Defi",
  "tags": ["reliability", "production", "wallet", "rpc", "websocket", "audit", "playbooks"]
}
```

Full integration guide: [`docs/AI-KIT-INTEGRATION.md`](docs/AI-KIT-INTEGRATION.md)

---

## Contact

- **GitHub:** https://github.com/Shaydez-Defi
- **Repo issues:** https://github.com/Shaydez-Defi/solana-dapp-reliability-skill/issues