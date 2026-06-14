# E01 — Plugin sequencing: can a phase run before brainstorming?

**Status:** GO — 5/5 with hook-asserted ordering; 0/3 without (see Lessons.md)
**Gate:** hard GO/NO-GO for the whole architecture. Do not start Milestone 3
until this resolves GO. (Plan, cross-cutting + M2 Step 4.)

## The design question

The plugin's architecture (spec §"loop", phases 1-2) assumes a phase
(`planning-session` / `environment-research`, ultimately the `orchestrator`) can
run **before** superpowers' `brainstorming` on a "let's build X" request,
*without overriding* superpowers' own brainstorming→writing-plans handoff.

superpowers' `using-superpowers` bootstrap explicitly routes build intent to
brainstorming ("Let's build X → brainstorming first"). The risk: that bootstrap
preempts our pre-brainstorm phase, making the prepend architecture invalid.

## Hypothesis

A pre-brainstorm skill, reinforced by a SessionStart hook that asserts the loop
ordering (exactly the mechanism the real plugin uses), takes precedence on a
"let's build X" prompt — i.e. it fires first, then hands off to superpowers
brainstorming. (Grounded in the documented precedence rule: user/project
instructions outrank skill defaults — but reasoning is a hypothesis; this probe
runs it.)

## Method

A controlled headless session (the experiment code is disposable, under
`scratch/`, gitignored):
1. A throwaway project with a project-level `planning-first` skill (proxy for the
   orchestrator) plus a project SessionStart hook injecting the ordering rule.
2. Send a positive build prompt ("let's build a small react todo list").
3. Parse the transcript: does `planning-first` fire before/instead of
   `brainstorming`, or does superpowers' brainstorming preempt it?
N=5 runs (determinism section); record each to `decisions.jsonl`.

## Kill criterion

If superpowers' bootstrap/handoff overrides the inserted phase (brainstorming
preempts on the majority of runs and the pre-phase cannot take precedence), this
is **NO-GO**: STOP, do not build M3, and switch to the ADR-0001
"shadow exactly one skill" fallback, re-planning M6.

## Result — GO

Headless probe (sonnet, 5 runs with the ordering instruction + 3 without):
- **5/5** with the project/hook ordering instruction ran the pre-phase
  (`planning-first`) before brainstorming, then handed off — no override of
  superpowers' handoff.
- **0/3** without it — the skill description alone lost to brainstorming.

Conclusion: the prepend architecture is valid (build M3), and the ordering must
be enforced by the SessionStart hook / project instruction, not by skill
descriptions (ADR-0003 is load-bearing). See `decisions.jsonl` and `Lessons.md`.
