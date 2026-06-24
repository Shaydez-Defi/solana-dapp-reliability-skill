#!/usr/bin/env bash
# Solana dApp Reliability Skill — structure validator
# Run from repo root: ./validate.sh
set -euo pipefail

PASS=0
FAIL=0
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

check() {
  local description="$1"
  local result="$2"
  if [ "$result" -eq 0 ]; then
    echo "  PASS: $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $description"
    FAIL=$((FAIL + 1))
  fi
}

file_exists() {
  [ -f "$1" ]
}

dir_exists() {
  [ -d "$1" ]
}

has_frontmatter_field() {
  local file="$1"
  local field="$2"
  head -1 "$file" | grep -q "^---" || return 1
  awk '/^---$/{c++;next} c==1{print; if(NR>30)exit}' "$file" | grep -q "^${field}:"
}

echo "Validating solana-dapp-reliability-skill..."
echo ""

# --- Core files ---
echo "[Core]"
for f in README.md LICENSE install.sh SUBMISSION.md validate.sh; do
  file_exists "${REPO_ROOT}/${f}" && r=0 || r=1
  check "$f exists" $r
done
echo ""

# --- SKILL.md router ---
echo "[SKILL Router]"
SKILL="${REPO_ROOT}/skill/SKILL.md"
if file_exists "$SKILL"; then
  check "skill/SKILL.md exists" 0
  has_frontmatter_field "$SKILL" "name" && r=0 || r=1
  check "SKILL.md has name:" $r
  has_frontmatter_field "$SKILL" "description" && r=0 || r=1
  check "SKILL.md has description:" $r
else
  check "skill/SKILL.md exists" 1
fi
echo ""

# --- Reliability modules (5 core) ---
echo "[Reliability Modules]"
MODULES=(
  wallet-failures.md
  transaction-failures.md
  state-sync-failures.md
  realtime-failures.md
  rpc-failures.md
)
for m in "${MODULES[@]}"; do
  file_exists "${REPO_ROOT}/skill/reliability/${m}" && r=0 || r=1
  check "skill/reliability/${m}" $r
done
echo ""

# --- Playbooks ---
echo "[Playbooks]"
PLAYBOOKS=(
  stale-balances.md
  tx-stuck.md
  websocket-failure.md
  wallet-reconnect.md
  rpc-outage.md
)
for p in "${PLAYBOOKS[@]}"; do
  file_exists "${REPO_ROOT}/skill/playbooks/${p}" && r=0 || r=1
  check "skill/playbooks/${p}" $r
done
echo ""

# --- Supporting knowledge ---
echo "[Supporting Knowledge]"
for f in \
  skill/migration/kit-migration.md \
  skill/anti-patterns/production-anti-patterns.md \
  skill/audits/reliability-checklist.md \
  rules/reliability-rules.md; do
  file_exists "${REPO_ROOT}/${f}" && r=0 || r=1
  check "$f" $r
done
echo ""

# --- Commands ---
echo "[Commands]"
COMMANDS=(
  reliability-audit.md
  tx-flow-audit.md
  frontend-health-check.md
  migrate-to-kit.md
)
for c in "${COMMANDS[@]}"; do
  file_exists "${REPO_ROOT}/commands/${c}" && r=0 || r=1
  check "commands/${c}" $r
done
echo ""

# --- SKILL.md router links resolve ---
echo "[Router Links]"
if file_exists "$SKILL"; then
  broken=0
  while IFS= read -r path; do
    [ -z "$path" ] && continue
    # Paths in SKILL.md are relative to skill/ or repo root
    if [[ "$path" == skill/* ]]; then
      target="${REPO_ROOT}/${path}"
    elif [[ "$path" == commands/* ]] || [[ "$path" == rules/* ]]; then
      target="${REPO_ROOT}/${path}"
    else
      target="${REPO_ROOT}/skill/${path}"
    fi
    if [ ! -e "$target" ]; then
      echo "  FAIL: Broken router reference -> $path"
      FAIL=$((FAIL + 1))
      broken=$((broken + 1))
    fi
  done < <(grep -oE '`[a-z0-9_./-]+\.md`' "$SKILL" | tr -d '`' | sort -u)

  if [ "$broken" -eq 0 ]; then
    check "All SKILL.md module references resolve" 0
  fi
else
  check "SKILL.md present for link check" 1
fi
echo ""

# --- install.sh ---
echo "[Installer]"
if file_exists "${REPO_ROOT}/install.sh"; then
  grep -q "SKILL_NAME" "${REPO_ROOT}/install.sh" && r=0 || r=1
  check "install.sh defines SKILL_NAME" $r
  grep -q "solana-dapp-reliability" "${REPO_ROOT}/install.sh" && r=0 || r=1
  check "install.sh targets solana-dapp-reliability" $r
fi
echo ""

# --- Examples (hackathon submission) ---
echo "[Examples]"
file_exists "${REPO_ROOT}/examples/demo-audit.md" && r=0 || r=1
check "examples/demo-audit.md exists" $r
echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "========================================="
echo "Results: $PASS passed, $FAIL failed (of $TOTAL checks)"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi