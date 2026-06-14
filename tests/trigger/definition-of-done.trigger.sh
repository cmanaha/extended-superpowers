#!/usr/bin/env bash
# Trigger + gate-presence contract test for the definition-of-done skill.
set -euo pipefail
cd "$(dirname "$0")/../.."

skill="plugins/extended-superpowers/skills/definition-of-done/SKILL.md"
[ -f "$skill" ] || { echo "missing skill: $skill"; exit 1; }
grep -q '^description: Use when' "$skill" || {
  echo "description must start with 'Use when': $skill"; exit 1; }

gate="plugins/extended-superpowers/hooks/definition-of-done.sh"
[ -x "$gate" ] || { echo "missing executable DoD gate: $gate"; exit 1; }
[ -f dod.config ] || { echo "missing dod.config"; exit 1; }

echo "ok: definition-of-done trigger contract + gate + config present"
