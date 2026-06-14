#!/usr/bin/env bash
# Trigger contract test for the planning-session skill.
set -euo pipefail
cd "$(dirname "$0")/../.."
skill="plugins/extended-superpowers/skills/planning-session/SKILL.md"
[ -f "$skill" ] || { echo "missing skill: $skill"; exit 1; }
grep -q '^description: Use when' "$skill" || { echo "description must start with 'Use when': $skill"; exit 1; }
[ -f "plugins/extended-superpowers/agents/research-scout.md" ] || { echo "missing research-scout agent"; exit 1; }
echo "ok: planning-session trigger contract + research-scout agent present"
