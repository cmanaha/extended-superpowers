#!/usr/bin/env bash
# Trigger + harness-presence contract test for the acceptance-tests skill.
# (The real headless trigger eval is scripts/eval.sh, run locally/nightly.)
set -euo pipefail
cd "$(dirname "$0")/../.."

skill="plugins/extended-superpowers/skills/acceptance-tests/SKILL.md"
[ -f "$skill" ] || { echo "missing skill: $skill"; exit 1; }
grep -q '^description: Use when' "$skill" || {
  echo "description must start with 'Use when': $skill"; exit 1; }

[ -x scripts/eval.sh ] || { echo "missing executable headless eval harness: scripts/eval.sh"; exit 1; }
# The skill must document the two-tier model (floor + real headless eval).
grep -qi 'positive' "$skill" && grep -qi 'negative' "$skill" || {
  echo "acceptance-tests skill must cover positive AND negative triggering"; exit 1; }

echo "ok: acceptance-tests trigger contract + eval harness present"
