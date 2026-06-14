#!/usr/bin/env bash
# Trigger test (static contract) for the environment-research skill.
# The real headless-session trigger test arrives in Milestone 4 (see plan); this
# asserts the triggering contract the description depends on.
set -euo pipefail
cd "$(dirname "$0")/../.."

skill="plugins/extended-superpowers/skills/environment-research/SKILL.md"
[ -f "$skill" ] || { echo "missing skill: $skill"; exit 1; }
grep -q '^description: Use when' "$skill" || {
  echo "description must start with 'Use when' (triggering contract): $skill"; exit 1; }
[ -f "plugins/extended-superpowers/skills/environment-research/reference.md" ] || {
  echo "missing harvest-format reference.md"; exit 1; }

echo "ok: environment-research trigger contract + harvest reference present"
