#!/usr/bin/env bash
# Trigger test (placeholder harness) for the walking-skeleton skill.
#
# The real harness (added with the acceptance-tests skill, see the plan) runs a
# headless Claude session against a positive prompt ("show me the extended
# superpowers loop") and a negative prompt, then parses the session transcript
# to confirm the skill fired exactly when it should.
#
# Until that lands, this test asserts the static contract the trigger depends on:
# the skill exists and its description starts with "Use when". This keeps CI
# honest without yet spending model calls.
set -euo pipefail
cd "$(dirname "$0")/../.."

skill="plugins/extended-superpowers/skills/extended-superpowers-overview/SKILL.md"

[ -f "$skill" ] || { echo "missing skill: $skill"; exit 1; }
grep -q '^description: Use when' "$skill" || {
  echo "description must start with 'Use when' (triggering contract): $skill"; exit 1; }

echo "ok: extended-superpowers-overview trigger contract present"
