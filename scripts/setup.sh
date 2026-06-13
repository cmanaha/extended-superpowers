#!/usr/bin/env bash
# setup.sh — run once after cloning. Wires the authorship guard so the
# no-AI-attribution rule is enforced on THIS clone, not just the author's.
#
# core.hooksPath is local git config and is never committed, so a fresh clone
# has the commit-msg hook present but inert until this runs. ci.sh additionally
# re-checks git history, so the guard holds even if this step is skipped.
set -euo pipefail
cd "$(dirname "$0")/.."

git config core.hooksPath .githooks
chmod +x .githooks/* scripts/*.sh \
  plugins/extended-superpowers/hooks/*.sh tests/trigger/*.sh 2>/dev/null || true

echo "✓ dev setup complete: commit-msg authorship guard active (core.hooksPath=.githooks)."
echo "  Author is Carlos Manzanedo Rueda. AI attribution in commits is blocked."
