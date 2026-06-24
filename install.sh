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

  cp "${REPO_DIR}/skill/SKILL.md" "${target_dir}/SKILL.md"
  cp "${REPO_DIR}/skill/reliability-framework.md" "${target_dir}/reliability-framework.md"
  cp "${REPO_DIR}/skill/production-readiness-checklist.md" "${target_dir}/production-readiness-checklist.md"

  for subdir in reliability playbooks migration anti-patterns; do
    if [[ -d "${REPO_DIR}/skill/${subdir}" ]]; then
      mkdir -p "${target_dir}/${subdir}"
      cp -r "${REPO_DIR}/skill/${subdir}/." "${target_dir}/${subdir}/"
    fi
  done

  echo "✓ Installed to ${target_dir}"
}

if [[ "${SCOPE}" == "global" ]]; then
  install_skill "${HOME}/.grok/skills"
else
  install_skill "$(pwd)/.grok/skills"
fi

[[ "${INSTALL_CURSOR}" == true ]] && install_skill "${HOME}/.cursor/skills"
[[ "${INSTALL_CLAUDE}" == true ]] && install_skill "${HOME}/.claude/skills"

echo ""
echo "Solana dApp Reliability skill installed."
echo "  /reliability-audit  — production readiness review"
echo "  Playbooks load first for: stale balance, stuck tx, can't sign, websocket, RPC outage"