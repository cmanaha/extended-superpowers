---
name: environment-research
description: Use when — before writing a spec or plan — you need to know how a dependency, library, API, CLI, or platform ACTUALLY behaves (its real execution, outcome, error, and boundary modes) rather than what its docs or source claim; triggers when an agent is about to design on top of an unverified dependency, or the user asks to probe, spike, characterise, or empirically test a tool's real behaviour before committing to a design.
---

# Environment Research — Probe Before You Design

Documentation tells you what a dependency is *supposed* to do. Reading its source
tells you what it was *written* to do. Neither tells you what it *actually* does
under your inputs, at its boundaries, or when it fails. You do not know until you
run it. Environment research is the disciplined, disposable experiment that turns
assumptions into observed facts **before** they harden into a spec.

## Core principle

A research brief built on documentation is a hypothesis. Validate the
load-bearing parts of it by running the dependency, not by reading more about it.

## When to use

- Before a spec/plan depends on a library, API, CLI, model, or platform whose
  real behaviour you have not observed.
- When the docs are thin, ambiguous, or suspected stale.
- When a boundary/error/concurrency behaviour will drive a design decision.

**Skip** for dependencies you have already empirically characterised, or for
pure-docs questions with no design consequence.

## The method

1. **State hypotheses about the dependency's modes.** For the specific thing you
   will rely on, write down your current belief about its:
   - execution mode (what it does on the happy path),
   - outcome mode (shape/type of what it returns),
   - error mode (how it fails — exception? null? partial write? silent?),
   - boundary mode (empty input, huge input, concurrency, timeouts, limits).
2. **Write minimal isolated experiments** — one per hypothesis — that exercise
   exactly that mode. Smallest code that produces an observation.
3. **Run them and record actual-vs-hypothesis.** Append one line per observation
   to `docs/experiments/<probe>/decisions.jsonl` (schema in `reference.md`).
4. **Provoke the failures on purpose.** Add deliberate negative/stress
   experiments — overflow the buffer, race two writers, pass the empty set.
   Producing the failure is the point; a mode you never triggered is a mode you
   did not characterise.
5. **Harvest.** Write `Lessons.md` — the findings in prose — and make a
   graduation decision: keep (findings feed the brief), iterate (more probing
   needed), or discard (no design consequence).
6. **Embed, don't migrate.** The findings go into the planning brief / spec. The
   experiment CODE stays in the disposable tree and is never imported by
   production.

## Isolation contract (non-negotiable)

- Experiments live under `docs/experiments/<probe>/scratch/` — gitignored,
  disposable, **zero coupling** to the production tree. Production code never
  imports from an experiment.
- The whole experiment tree is a single delete target: if the findings don't
  justify it, `rm -rf` the probe dir and only `Lessons.md` + `decisions.jsonl`
  remain as the kept record.

## Harvest contract

Disposable code, kept knowledge. After every probe these survive:
- `docs/experiments/<probe>/decisions.jsonl` — one observation per line.
- `docs/experiments/<probe>/Lessons.md` — the findings + the graduation decision.
See `reference.md` for the exact formats.

## Red flags — stop

- Reasoning about a dependency's behaviour from docs/source without running it.
- Keeping experiment code as "reference" inside production.
- Running the happy path only and declaring the dependency understood.
- Finishing a probe with no `decisions.jsonl` line and no `Lessons.md`.

## Output

A planning brief whose load-bearing claims about each probed dependency are
backed by an observation in `decisions.jsonl`, not by a documentation citation.
