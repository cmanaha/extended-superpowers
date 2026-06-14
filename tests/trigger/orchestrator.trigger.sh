#!/usr/bin/env bash
# Trigger + loop-completeness contract test for the orchestrator skill.
set -euo pipefail
cd "$(dirname "$0")/../.."
skill="plugins/extended-superpowers/skills/orchestrator/SKILL.md"
[ -f "$skill" ] || { echo "missing skill: $skill"; exit 1; }
grep -q '^description: Use when' "$skill" || { echo "description must start with 'Use when': $skill"; exit 1; }
# The orchestrator must name all seven phases.
for phase in planning-session environment-research brainstorming writing-plans \
             subagent-driven-development acceptance-tests definition-of-done; do
  grep -qF "$phase" "$skill" || { echo "orchestrator missing phase: $phase"; exit 1; }
done
echo "ok: orchestrator trigger contract + all 7 phases present"
