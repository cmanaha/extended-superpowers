# ADR-0003: SessionStart hook for reliable skill activation

**Date:** 2026-06-12
**Status:** Accepted

## Context

Skills are easy for the model to ignore without a prompt-time nudge. superpowers
ships a SessionStart hook (its `using-superpowers` bootstrap) precisely to make
its skills auto-trigger. Independent measurements report skill activation is
strongly improved by a SessionStart / forced-evaluation hook (treated here as a
directional finding, not a precise number).

## Decision

Ship a SessionStart hook that injects a short pointer to the
`extended-superpowers-overview` skill and the loop ordering, so the orchestrator
and phase skills trigger at the right moments. The hook only emits
`additionalContext`; it never blocks and has no side effects.

## Consequences

- Activation reliability is a property of the plugin, not of the host setup.
- The hook is the lowest-risk, highest-leverage activation mechanism; behavioural
  enforcement (e.g. the definition-of-done gate) is a separate, later hook.
