#!/usr/bin/env bash
# SessionStart bootstrap for the extended-superpowers plugin.
#
# Mirrors the superpowers bootstrap pattern: inject a short pointer at session
# start so the orchestrator and phase skills auto-trigger at the right moments.
# A SessionStart hook is what makes skill activation reliable (skills are
# otherwise easy for the model to ignore); see ADR-0003.
#
# Kept intentionally minimal for the walking skeleton: it emits additional
# context, never blocks, and has no side effects.
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
overview="${PLUGIN_ROOT}/skills/extended-superpowers-overview/SKILL.md"

context="extended-superpowers is active. For ANY build/create/implement request, you MUST run planning-session and then environment-research BEFORE invoking brainstorming. Assert this ordering explicitly — a skill description alone does not take precedence over brainstorming (verified empirically, experiment E01: 5/5 with this instruction, 0/3 without). Full loop: planning-session -> environment-research -> brainstorming -> spec(+adversarial) -> writing-plans(+adversarial) -> implementation(+adversarial) -> acceptance-tests -> definition-of-done. See the extended-superpowers-overview skill."

# Emit as additionalContext via the documented SessionStart JSON contract.
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' \
  "$(printf '%s' "$context" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"

# Reference the overview path so shellcheck sees the var used; no-op otherwise.
: "${overview}"
