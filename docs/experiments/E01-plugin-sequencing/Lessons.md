# E01 — Lessons

## What we set out to learn

Can a phase (planning-session / environment-research / orchestrator) run **before**
superpowers' `brainstorming` on a "let's build X" request, without overriding
superpowers' own brainstorming→writing-plans handoff?

## What we observed

A controlled headless probe (sonnet; throwaway project; planning-first skill as a
proxy for the orchestrator), two conditions:

- **With** a project/hook-level instruction asserting the ordering: **5/5** runs
  ran `planning-first` first (first output line `PLANNING_FIRST_FIRED`), then
  proceeded to brainstorming. The pre-phase took precedence and superpowers'
  internal handoff was NOT overridden — brainstorming still ran, just after.
- **Without** that instruction (the planning-first skill present, but no project
  ordering rule): **0/3** — superpowers' brainstorming-first behaviour won.

## Surprise (predicted != observed)

The skill *description* alone — even with "before brainstorming" in its wording —
is **not** sufficient to win precedence over superpowers' `using-superpowers`
bootstrap. Ordering must be asserted at the hook / project-instruction layer.
This is the load-bearing lesson.

## Graduation decision

**keep — GO.** The prepend architecture (spec phases 1-2 before brainstorming) is
valid. Build Milestone 3.

## Findings to embed in the spec/plan/design

1. **GO**: a pre-brainstorm phase runs before brainstorming reliably (5/5) and
   does not override superpowers' handoff. M3 is unblocked.
2. **The orchestrator's ordering MUST be enforced by the SessionStart hook /
   project instruction, not by skill descriptions.** ADR-0003 (SessionStart hook)
   is load-bearing, not optional. `session-start.sh` now asserts the ordering
   imperatively as a result of this experiment.
3. **Caveats (honest scope):** validated with a project-`CLAUDE.md` proxy for the
   plugin's hook, on `sonnet`, observing the first turn (max-turns 2). A more
   capable model is at least as likely to follow the instruction. The definitive
   end-to-end confirmation with the actually-installed plugin + its real
   SessionStart hook remains a one-time manual check, but the precedence
   *mechanism* (hook/project instruction outranks skill default) is confirmed.

## Disposition of experiment code

The experiment ran under an ephemeral `/tmp` project (disposable by definition);
nothing was migrated into the repo. Only this file, `decisions.jsonl`, and the
README are kept.
