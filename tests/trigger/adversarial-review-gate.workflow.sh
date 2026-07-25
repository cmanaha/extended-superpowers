#!/usr/bin/env bash
# Contract test for the shipped adversarial-review-gate workflow.
#
# The workflow exists to make the lens contract structural rather than advisory,
# so these checks assert the properties that would silently rot if the script
# drifted from skills/adversarial-review/SKILL.md:
#   1. it lives where a plugin ships workflows (workflows/ at the plugin root)
#   2. meta.name is present — it names the slash command, not the filename
#   3. the spec and plan lens sets are complete in the script, not just the skill
#   4. it dispatches the bundled reviewer agents, not a single generic reviewer
#   5. it is enumerate-only and short-circuits code-quality on a dirty compliance
#      pass (the binding order from the skill)
#   6. it stays inside the API subset E02 sanctioned
set -euo pipefail
cd "$(dirname "$0")/../.."

wf="plugins/extended-superpowers/workflows/adversarial-review-gate.js"
[ -f "$wf" ] || { echo "missing workflow: $wf"; exit 1; }

grep -qE "^[[:space:]]*name: 'adversarial-review-gate'," "$wf" || {
  echo "workflow must declare meta.name (it names /<plugin>:<meta.name>)"; exit 1; }
grep -q 'whenToUse:' "$wf" || { echo "workflow should declare meta.whenToUse"; exit 1; }

# The lens sets must be complete in the SCRIPT. The skill's table is prose; this
# is the loop bound, and a dropped lens here silently narrows every review.
spec_lenses=("factual-grounding" "completeness" "design-flaw/race" "testability/DoD")
plan_lenses=("spec-coverage+guardrails" "testing+trackability" "sequencing+anti-hubris")
for l in "${spec_lenses[@]}" "${plan_lenses[@]}"; do
  grep -qF "$l" "$wf" || { echo "missing lens in workflow lens table: $l"; exit 1; }
done

# One fresh reviewer per lens, using the bundled agents — a single generic
# reviewer must not be able to stand in for the set.
for a in adversarial-reviewer spec-compliance-reviewer code-quality-reviewer; do
  grep -qF "agentType: '$a'" "$wf" || { echo "workflow must dispatch bundled agent: $a"; exit 1; }
done

# Enumerate-only, and the binding implementation order.
grep -qi 'ENUMERATE, DO NOT FIX' "$wf" || {
  echo "workflow reviewers must be instructed enumerate-only"; exit 1; }
grep -qF "skipped = 'code-quality'" "$wf" || {
  echo "workflow must short-circuit code-quality when spec-compliance is dirty"; exit 1; }

# A gate that cannot say NO-GO is not a gate.
grep -qF "'NO-GO'" "$wf" || { echo "workflow must be able to return NO-GO"; exit 1; }

# E02 sanctioned the documented core + phase()/log()/schema/agentType only.
# budget, nested workflow() and resumeFromRunId stay out until first-party docs
# cover them (docs/experiments/E02-plugin-workflows/Lessons.md).
for banned in 'budget.' 'resumeFromRunId'; do
  if grep -qF "$banned" "$wf"; then
    echo "workflow uses undocumented API: $banned"; exit 1
  fi
done

echo "ok: adversarial-review-gate workflow — 7 lenses, 3 bundled agents, enumerate-only, NO-GO capable"
