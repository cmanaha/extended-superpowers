# ADR-0002: Skill evals fold into the acceptance-tests tier

**Date:** 2026-06-12
**Status:** Accepted

## Context

A plugin made of behaviour-shaping skills needs to verify those skills actually
(a) trigger when they should and stay silent when they should not, and (b)
produce the intended outcome when followed. The ecosystem offers several tools:
the official `skill-creator` (eval + benchmark + description tuner, installed
locally), `superpowers:writing-skills` (RED/GREEN baseline pressure testing),
`promptfoo` (Claude Agent SDK provider + `skill-used` assertion + CI gates), and
`cc-plugin-eval` (plugin-component trigger testing with positive/negative cases).

These are not a separate concern: a skill's eval *is* its acceptance test —
observable outcome ("the skill fired and produced its artifact"), not internal
code.

## Decision

Skill evals are part of the acceptance-tests tier, not a separate milestone.
- **Floor (always):** dependency-free trigger tests — headless Claude session,
  parse the transcript for the skill firing on positive prompts and not firing
  on negative prompts. Lives in `tests/trigger/`, runs in `scripts/ci.sh`.
- **Raise the bar where it pays:** add one harness (`promptfoo` or
  `cc-plugin-eval`) with positive/negative triggering plus behavioural rubrics
  for the highest-value skills (adversarial-review, the definition-of-done gate),
  run with a free judge model to avoid spending Claude credits.
- **Dev-time:** tune each skill's `description` with `skill-creator` before
  shipping.

## Consequences

- No separate "evals" milestone; the acceptance-tests skill owns them.
- The SessionStart hook (ADR-0003) is part of making triggering reliable.
- Evals live in this repo's CI, dogfooding the acceptance tier the plugin ships.
