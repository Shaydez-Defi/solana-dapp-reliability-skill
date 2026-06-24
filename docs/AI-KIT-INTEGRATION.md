# Solana AI Kit Integration

How to add `solana-dapp-reliability-skill` to [solana-ai-kit](https://github.com/solanabr/solana-ai-kit).

---

## Option 1: Submodule (recommended for AI Kit)

From your project root after installing solana-ai-kit:

```bash
git submodule add https://github.com/Shaydez-Defi/solana-dapp-reliability-skill.git \
  .claude/skills/ext/solana-dapp-reliability
```

The skill router lives at:

```
.claude/skills/ext/solana-dapp-reliability/skill/SKILL.md
```

Wire it into the kit's skill hub by adding a reference in `.claude/skills/SKILL.md` or the kit's skill registry.

---

## Option 2: skill-registry.json entry

Add to `.claude/skills/skill-registry.json`:

```json
{
  "id": "solana-dapp-reliability",
  "name": "Solana dApp Reliability",
  "type": "skill",
  "domain": "solana-frontend",
  "description": "Diagnose and recover from production failures in Solana dApps. Five-layer framework, reliability score output, playbooks, 10-item checklist. Commands: /reliability-audit, /tx-flow-audit, /frontend-health-check, /migrate-to-kit.",
  "source": "https://github.com/Shaydez-Defi/solana-dapp-reliability-skill",
  "install": {
    "method": "submodule",
    "command": "git submodule add https://github.com/Shaydez-Defi/solana-dapp-reliability-skill.git .claude/skills/ext/solana-dapp-reliability",
    "env": []
  },
  "license": "MIT",
  "maintainer": "Shaydez-Defi",
  "signal": { "reputability": "community" },
  "default_installed": false,
  "safety": "clean — pure markdown, no scripts executed at runtime",
  "tags": ["reliability", "production", "wallet", "rpc", "websocket", "audit", "playbooks"]
}
```

---

## Option 3: Standalone install (no full AI Kit)

```bash
curl -fsSL https://raw.githubusercontent.com/Shaydez-Defi/solana-dapp-reliability-skill/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/Shaydez-Defi/solana-dapp-reliability-skill.git
cd solana-dapp-reliability-skill
./install.sh --global        # ~/.grok/skills/ or ~/.claude/skills/
./install.sh --global --cursor
```

---

## Routing from AI Kit SKILL.md hub

Add this row to the kit's skill router table:

| User intent | Load |
|-------------|------|
| dApp reliability, stale balances, wallet can't sign, RPC outage, tx stuck, production audit | `ext/solana-dapp-reliability/skill/SKILL.md` |

The reliability skill's own router then loads only the relevant file — playbook first for symptoms, framework + checklist for audits.

---

## Intent → File Mapping

| User intent | Files loaded |
|-------------|--------------|
| `/reliability-audit` | `reliability-framework.md` → `production-readiness-checklist.md` → `reliability-score.md` |
| `/frontend-health-check` | `reliability-framework.md` → `production-readiness-checklist.md` → `reliability-score.md` |
| `/tx-flow-audit` | `reliability-framework.md` (Layer 2) → `playbooks/tx-stuck.md` → `reliability/transaction-failures.md` |
| `/migrate-to-kit` | `migration/kit-migration.md` |
| Stale balance | `playbooks/stale-balances.md` |
| Stuck transaction | `playbooks/tx-stuck.md` |
| Wallet can't sign | `playbooks/wallet-cannot-sign.md` |
| Websocket silence | `playbooks/websocket-failure.md` |
| RPC outage / 429 | `playbooks/rpc-outage.md` |

Progressive loading rule: max 2 files per debug turn, max 3 for audits.

---

## Complementary skills (no overlap)

| AI Kit skill | Focus | This skill complements by… |
|--------------|-------|---------------------------|
| `ext/solana-dev` | Build programs + frontend | Diagnosing production failures post-build |
| `ext/sendai` | DeFi protocol integrations | Recovering from stale state after swaps/deposits |
| `ext/solana-mobile` | Mobile Wallet Adapter setup | Playbook for wallet-can't-sign on mobile |
| `ext/helius` | RPC infrastructure | Failover when primary RPC degrades |

---

## Validate installation

```bash
cd solana-dapp-reliability-skill
./validate.sh
```

All checks should pass before submitting to Superteam Earn or opening a PR to solana-ai-kit.