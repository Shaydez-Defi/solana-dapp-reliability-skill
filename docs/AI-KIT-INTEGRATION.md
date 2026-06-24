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
.claude/skills/ext/solana-dapp-reliability/SKILL.md
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
  "description": "Diagnose and prevent production failures in Solana dApps: stale balances, wallet disconnects, RPC outages, websocket drops, tx confirmation issues. Commands: /reliability-audit, /tx-flow-audit, /frontend-health-check, /migrate-to-kit.",
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
  "tags": ["reliability", "frontend", "wallet", "rpc", "websocket", "production", "audit", "kit-migration"]
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
| dApp reliability, stale balances, wallet reconnect, RPC outage, tx stuck, production audit | `ext/solana-dapp-reliability/skill/SKILL.md` |

The reliability skill's own router then loads only the relevant submodule (wallet, tx, state, realtime, RPC, or playbooks).

---

## Commands mapping

| This skill | AI Kit namespaced equivalent |
|------------|------------------------------|
| `/reliability-audit` | `/solana-dapp-reliability:reliability-audit` (if installed as plugin) |
| `/tx-flow-audit` | Load `commands/tx-flow-audit.md` via skill router |
| `/frontend-health-check` | Load `commands/frontend-health-check.md` |
| `/migrate-to-kit` | Load `commands/migrate-to-kit.md` + `skill/migration/kit-migration.md` |

---

## Complementary skills (no overlap)

| AI Kit skill | Focus | This skill complements by… |
|--------------|-------|---------------------------|
| `ext/solana-dev` | Build programs + frontend | Covering production failure modes post-build |
| `ext/sendai` | DeFi protocol integrations | Handling stale state after swaps/deposits |
| `ext/solana-mobile` | Mobile Wallet Adapter setup | Debugging mobile reconnect and deep-link failures |
| `ext/helius` | RPC infrastructure | Failover patterns when Helius degrades |

---

## Validate installation

```bash
cd solana-dapp-reliability-skill
./validate.sh
```

All checks should pass before submitting to Superteam Earn or opening a PR to solana-ai-kit.