#!/usr/bin/env bash
# marketplace-install.test.sh — end-to-end install smoke test.
#
# Adds this repo as a marketplace and installs the plugin inside a
# throwaway CLAUDE_CONFIG_DIR, so the real user config is never touched.
# Regression guard for issue #1: a bare-string plugin source resolved via
# metadata.pluginRoot is rejected by Claude Code >= 2.1.206 as an
# "unsupported source type"; the source must be an explicit ./ path.
set -euo pipefail
cd "$(dirname "$0")/../.."
repo_root=$(pwd)

if ! command -v claude >/dev/null 2>&1; then
  echo "skip: claude CLI not found (CI installs it)"
  exit 0
fi

sandbox=$(mktemp -d)
trap 'rm -rf "$sandbox"' EXIT
export CLAUDE_CONFIG_DIR="$sandbox"

out=$(claude plugin marketplace add "$repo_root" 2>&1) || {
  echo "FAIL: marketplace add exited non-zero:"
  echo "$out"
  exit 1
}
case "$out" in
  *"Successfully added marketplace"*) ;;
  *) echo "FAIL: marketplace add did not report success:"
     echo "$out"
     exit 1 ;;
esac

out=$(claude plugin install extended-superpowers@cmanaha --scope user 2>&1) || {
  echo "FAIL: plugin install exited non-zero:"
  echo "$out"
  exit 1
}
case "$out" in
  *"Successfully installed plugin"*) ;;
  *) echo "FAIL: plugin install did not report success:"
     echo "$out"
     exit 1 ;;
esac

echo "ok: marketplace add + plugin install succeed in a clean sandbox"
