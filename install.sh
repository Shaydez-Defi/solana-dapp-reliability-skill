#!/usr/bin/env bash
# Install solana-dapp-reliability-skill for Grok, Cursor, or Claude Code
set -euo pipefail

SKILL_NAME="solana-dapp-reliability"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: ./install.sh [OPTIONS]

Install the Solana dApp Reliability skill for AI coding agents.

Options:
  --global, -g     Install to ~/.grok/skills/ (available in all projects)
  --project, -p    Install to .grok/skills/ in current directory (default)
  --cursor         Also install to ~/.cursor/skills/
  --claude         Also install to ~/.claude/skills/
  --help, -h       Show this help

Examples:
  ./install.sh                  # Install in current project
  ./install.sh --global         # Install for all projects
  ./install.sh -g --cursor      # Global + Cursor compatibility
EOF
}

SCOPE="project"
INSTALL_CURSOR=false
INSTALL_CLAUDE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global|-g) SCOPE="global"; shift ;;
    --project|-p) SCOPE="project"; shift ;;
    --cursor) INSTALL_CURSOR=true; shift ;;
    --claude) INSTALL_CLAUDE=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

install_skill() {
  local target_base="$1"
  local target_dir="${target_base}/${SKILL_NAME}"

  mkdir -p "${target_dir}"

  # SKILL.md router
  cp "${REPO_DIR}/skill/SKILL.md" "${target_dir}/SKILL.md"

  # Knowledge modules
  for subdir in framework reliability playbooks patterns migration anti-patterns audits commands rules; do
    if [[ -d "${REPO_DIR}/skill/${subdir}" ]]; then
      mkdir -p "${target_dir}/${subdir}"
      cp -r "${REPO_DIR}/skill/${subdir}/." "${target_dir}/${subdir}/"
    fi
  done

  echo "✓ Installed to ${target_dir}"
}

# Primary install
if [[ "${SCOPE}" == "global" ]]; then
  install_skill "${HOME}/.grok/skills"
else
  install_skill "$(pwd)/.grok/skills"
fi

# Optional compatibility installs
if [[ "${INSTALL_CURSOR}" == true ]]; then
  install_skill "${HOME}/.cursor/skills"
fi

if [[ "${INSTALL_CLAUDE}" == true ]]; then
  install_skill "${HOME}/.claude/skills"
fi

echo ""
echo "Solana dApp Reliability skill installed."
echo ""
echo "Usage:"
echo "  /solana-dapp-reliability     Run the skill"
echo "  /reliability-audit           Audit codebase reliability"
echo "  /tx-flow-audit               Audit transaction pipeline"
echo "  /frontend-health-check       Review frontend architecture"
echo "  /migrate-to-kit              web3.js → @solana/kit guidance"
echo ""
echo "The skill auto-invokes when you ask about Solana dApp failures,"
echo "stale balances, wallet issues, RPC outages, or production reliability."