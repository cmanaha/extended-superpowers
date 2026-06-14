---
name: orchestrator
description: Use when starting any multi-step build, create, or implement task — sequences the full extended-superpowers loop and drives each phase in order, delegating to superpowers where it already does the job; triggers on "let's build/implement/create X" and on any request that will become a spec → plan → code → ship.
---

# Orchestrator — the loop driver

Sequences the seven phases in order. It owns the new phases and delegates the
rest to superpowers; it never overrides superpowers' internal handoffs, it
sequences around them.

## The loop

1. **planning-session** (this plugin) — bounded, budgeted research → brief.
2. **environment-research** (this plugin) — probe the dependencies the brief
   leans on; harvest findings into the brief.
3. **brainstorming** (superpowers) → spec, then **adversarial-review** on the
   spec (lenses: factual-grounding, completeness, design-flaw/race, testability/DoD).
4. **writing-plans** (superpowers) → plan, then **adversarial-review** on the
   plan (lenses: spec-coverage+guardrails, testing+trackability, sequencing+anti-hubris).
5. **subagent-driven-development** (superpowers) → code, with **adversarial-review**
   at the spec-compliance then code-quality seams.
6. **acceptance-tests** (this plugin) — observable-outcome tests; for skills, the
   real headless trigger evals.
7. **definition-of-done** (this plugin) — run the tooling-enforced gate before
   any completion claim. NO-GO blocks "done".

## Ordering is enforced, not assumed

Phases 1-2 run BEFORE brainstorming. This works because the SessionStart hook
asserts the ordering — a skill description alone is not enough to take precedence
over superpowers' brainstorming-first bootstrap (verified, experiment E01: 5/5
with the hook-asserted ordering, 0/3 without). Do not rely on description wording
for precedence; the hook carries it.

## Delegation

Reuse superpowers for brainstorming, writing-plans, subagent-driven-development,
test-driven-development, and verification-before-completion. Reuse this repo's and
the user's existing review agents (staff-engineer-reviewer, pr-review-toolkit) for
the adversarial gates. Only add what superpowers lacks; do not boil the ocean.

## Red flags — stop

- Jumping into brainstorming on a build request without running planning-session
  and environment-research first.
- Skipping an adversarial gate at spec, plan, or implementation.
- Claiming "done" without the definition-of-done gate returning GO.
- Re-implementing something superpowers already provides.
