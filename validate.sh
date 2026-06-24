#!/usr/bin/env bash
# Solana dApp Reliability Skill — focused structure validator
set -euo pipefail

PASS=0
FAIL=0
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="${REPO_ROOT}/skill"

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

file_exists() { [ -f "$1" ]; }

echo "Validating solana-dapp-reliability-skill (focused ship)..."
echo ""

echo "[Core]"
for f in README.md LICENSE install.sh SUBMISSION.md validate.sh; do
  file_exists "${REPO_ROOT}/${f}" && check "$f" 0 || check "$f" 1
done
echo ""

echo "[Framework — load first]"
for f in SKILL.md reliability-framework.md production-readiness-checklist.md; do
  file_exists "${SKILL_ROOT}/${f}" && check "skill/${f}" 0 || check "skill/${f}" 1
done
echo ""

echo "[Reliability Modules]"
for m in wallet-failures.md transaction-failures.md state-sync-failures.md realtime-failures.md rpc-failures.md; do
  file_exists "${SKILL_ROOT}/reliability/${m}" && check "reliability/${m}" 0 || check "reliability/${m}" 1
done
echo ""

echo "[Playbooks — first-class]"
for p in stale-balances.md tx-stuck.md wallet-cannot-sign.md websocket-failure.md rpc-outage.md; do
  file_exists "${SKILL_ROOT}/playbooks/${p}" && check "playbooks/${p}" 0 || check "playbooks/${p}" 1
done
echo ""

echo "[Supporting]"
for f in migration/kit-migration.md anti-patterns/production-anti-patterns.md; do
  file_exists "${SKILL_ROOT}/${f}" && check "skill/${f}" 0 || check "skill/${f}" 1
done
echo ""

echo "[Scope — removed dirs must not exist]"
for d in patterns framework audits commands rules; do
  [ ! -d "${SKILL_ROOT}/${d}" ] && check "no skill/${d}/ (scope trimmed)" 0 || check "no skill/${d}/" 1
done
echo ""

echo "[Examples]"
file_exists "${REPO_ROOT}/examples/demo-audit.md" && check "examples/demo-audit.md" 0 || check "examples/demo-audit.md" 1
echo ""

TOTAL=$((PASS + FAIL))
echo "========================================="
echo "Results: $PASS passed, $FAIL failed (of $TOTAL)"
echo "========================================="
[ "$FAIL" -eq 0 ] || exit 1