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

# The bundled review agents must exist and be enumerate-only (so the loop is
# self-contained — no reliance on a personal/external agent).
for a in adversarial-reviewer spec-compliance-reviewer code-quality-reviewer; do
  agent="plugins/extended-superpowers/agents/$a.md"
  [ -f "$agent" ] || { echo "missing bundled agent: $agent"; exit 1; }
  grep -qiE 'enumerate' "$agent" || { echo "agent must be enumerate-only: $a"; exit 1; }
done

echo "ok: adversarial-review trigger + 9-lens contract + 3 bundled review agents (enumerate-only)"
