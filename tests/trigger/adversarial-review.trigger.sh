#!/usr/bin/env bash
# Trigger + lens-completeness contract test for the adversarial-review skill.
# Static checks (the real headless behavioural eval lands in Milestone 4):
#  1. triggering contract (description starts with "Use when")
#  2. the FULL named-lens set is present and mapped (a single generic reviewer
#     must not be able to stand in for the set).
set -euo pipefail
cd "$(dirname "$0")/../.."

skill="plugins/extended-superpowers/skills/adversarial-review/SKILL.md"
[ -f "$skill" ] || { echo "missing skill: $skill"; exit 1; }
grep -q '^description: Use when' "$skill" || {
  echo "description must start with 'Use when': $skill"; exit 1; }

lenses=(
  "factual-grounding" "completeness" "design-flaw/race" "testability/DoD"
  "spec-coverage+guardrails" "testing+trackability" "sequencing+anti-hubris"
  "spec-compliance" "code-quality"
)
missing=0
for l in "${lenses[@]}"; do
  grep -qF "$l" "$skill" || { echo "missing lens in contract: $l"; missing=1; }
done
[ "$missing" -eq 0 ] || { echo "lens contract incomplete"; exit 1; }

# The reviewer agent must exist and be enumerate-only.
agent="plugins/extended-superpowers/agents/adversarial-reviewer.md"
[ -f "$agent" ] || { echo "missing agent: $agent"; exit 1; }
grep -qiE 'enumerate' "$agent" || { echo "reviewer agent must be enumerate-only"; exit 1; }

echo "ok: adversarial-review trigger + full 9-lens contract + reviewer agent present"
