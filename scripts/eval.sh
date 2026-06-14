#!/usr/bin/env bash
# eval.sh — real headless skill-trigger eval (model calls; run locally/nightly,
# NOT in the CI-safe ci.sh). Copies a plugin skill into a throwaway project, runs
# claude -p with a positive and a negative prompt N times, and checks the skill
# fires when it should and stays silent when it should not.
#
# Usage: scripts/eval.sh <skill-name> "<positive prompt>" "<negative prompt>" [N]
# Thresholds (determinism): positive-fire >= ceil(0.8N), negative-fire <= floor(0.2N).
set -euo pipefail
cd "$(dirname "$0")/.."

skill="${1:?skill name}"; pos="${2:?positive prompt}"; neg="${3:?negative prompt}"; N="${4:-5}"
src="plugins/extended-superpowers/skills/$skill"
[ -d "$src" ] || { echo "no such skill: $src"; exit 1; }

proj="$(mktemp -d)/proj"; mkdir -p "$proj/.claude/skills"
cp -R "$src" "$proj/.claude/skills/$skill"
trap 'rm -rf "$(dirname "$proj")"' EXIT

fired () { # prompt -> prints 1 if the skill fired, else 0
  ( cd "$proj" && claude -p "$1" --model sonnet --output-format stream-json \
      --verbose --max-turns 2 --permission-mode bypassPermissions --add-dir "$proj" \
      < /dev/null 2>/dev/null ) | grep -qE "\"skill\":\"$skill\"" && echo 1 || echo 0
}

posfires=0; negfires=0
for i in $(seq 1 "$N"); do posfires=$((posfires+$(fired "$pos"))); done
for i in $(seq 1 "$N"); do negfires=$((negfires+$(fired "$neg"))); done

pass_pos=$(( (8*N + 9) / 10 ))   # ceil(0.8N)
pass_neg=$(( (2*N) / 10 ))       # floor(0.2N)
echo "skill=$skill  positive-fire=$posfires/$N (need >=$pass_pos)  negative-fire=$negfires/$N (need <=$pass_neg)"

if [ "$posfires" -ge "$pass_pos" ] && [ "$negfires" -le "$pass_neg" ]; then
  echo "✓ PASS: $skill triggers correctly"; exit 0
elif [ "$posfires" -lt "$pass_pos" ] && [ "$posfires" -gt 0 ]; then
  echo "⚠ QUARANTINE: $skill grey-band ($posfires/$N) — fix the description, do not ship"; exit 2
else
  echo "✗ FAIL: $skill triggering does not meet thresholds"; exit 1
fi
