# extended-superpowers — Design Spec

**Date:** 2026-06-12
**Status:** Approved (build authorized)
**Author:** Carlos Manzanedo Rueda

## Goal

A reusable Claude Code plugin that extends superpowers with a research-first,
adversarially-reviewed, acceptance-gated development loop — distributable from a
public marketplace, installable in isolation on any machine, and pristine enough
to put the author's name on.

## Non-goals

- Not a fork of superpowers (see ADR-0001).
- Not a replacement for superpowers' brainstorming / writing-plans /
  subagent-driven-development — those are reused.
- Not a general agent framework; it is a methodology layer.

## The loop

| # | Phase | Owner | Artifact |
|---|-------|-------|----------|
| 1 | Planning session | this plugin | research brief (primary-source-checked) |
| 2 | Environment research | this plugin | findings note + graduation decision |
| 3 | Brainstorming → spec | superpowers + adversarial review | spec |
| 4 | Writing-plans → plan | superpowers + adversarial review | plan |
| 5 | Subagent-driven-development | superpowers + adversarial review | code |
| 6 | Acceptance tests | this plugin | executable observable-outcome tests |
| 7 | Definition of done | this plugin | green gate (tooling-enforced) |

Phases 1-2 prepend before brainstorming (no override of superpowers' handoffs).
Phases 3-5 attach adversarial review at superpowers' existing review seams.
Phases 6-7 extend verification-before-completion and finishing-a-branch.

## Components

### Skills
- `extended-superpowers-overview` — surfaces the loop (walking skeleton).
- `planning-session` — bounded/budgeted research; brief-as-hypothesis; every
  load-bearing claim cross-checked against the primary source.
- `environment-research` — hypothesis → isolated disposable experiments under
  `docs/experiments/<probe>/` (gitignored scratch) → `decisions.jsonl` +
  Lessons → keep/iterate/discard graduation → harvest findings into the brief.
- `adversarial-review` — parameterised by artifact (spec/plan/impl). Runs the
  named lenses in parallel, separate model from the author, "enumerate, don't
  fix", loop until clean. Reuses `staff-engineer-reviewer` and pr-review-toolkit
  agents; queries Open Brain for the governing principle where available.
- `acceptance-tests` — executable observable-outcome tests (what the user sees).
  Owns skill-trigger evals (ADR-0002).
- `definition-of-done` — assembles and runs the per-project DoD gate.
- `orchestrator` (a.k.a. the loop driver) — sequences phases 1-7, delegating to
  superpowers where it already does the job.

### Agents
- `adversarial-reviewer` — a fresh-eyes reviewer with a single named lens.
- `research-scout` — bounded research worker with a token budget.

### Hooks
- `session-start.sh` — activation bootstrap (ADR-0003).
- `definition-of-done.sh` — the DoD gate (added with phase 7).

## Named adversarial lenses (the review contract)

- Spec: factual-grounding, completeness, design-flaw/race, testability/DoD.
- Plan: spec-coverage+guardrails, testing+trackability, sequencing+anti-hubris
  (don't boil the ocean — justify every number).
- Implementation: spec-compliance, then code-quality (keep both — they catch
  different classes of bug).

## Distribution

This repo is the marketplace (`cmanaha`) and hosts the plugin
(`extended-superpowers`). Install anywhere:
`/plugin marketplace add cmanaha/extended-superpowers` then
`/plugin install extended-superpowers@cmanaha`. superpowers resolves as a
declared dependency.

## Definition of done (for the plugin itself)

`claude plugin validate` passes; `scripts/ci.sh` green; every skill passes its
trigger/acceptance tests; the DoD gate (once built) passes; author is Carlos
Manzanedo Rueda with zero AI attribution (commit-msg hook enforced).

## Success criteria (observable)

1. On a fresh machine, the two install commands produce a working plugin with
   superpowers auto-resolved.
2. Asking "show me the extended superpowers loop" triggers
   `extended-superpowers-overview`; an unrelated prompt does not.
3. Each phase skill triggers on its positive prompts and stays silent on its
   negatives (trigger evals green in CI).
4. The DoD gate blocks a "done" claim when any criterion fails.
