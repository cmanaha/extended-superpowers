# ADR-0004: Eval harness — in-repo headless floor, external harness optional

**Date:** 2026-06-13
**Status:** Accepted (extends ADR-0002)

## Context

Skills must be verified to trigger correctly (fire on positives, stay silent on
negatives) and, eventually, to produce their artifact. Candidate harnesses: an
in-repo headless approach (`claude -p` + transcript parse, the technique proven
in experiment E01), `promptfoo` (Claude Agent SDK provider + `skill-used`
assertion + CI gates), and `cc-plugin-eval` (plugin-component trigger testing).

## Decision

Two tiers, no external dependency required to ship:

1. **Floor — CI-safe (no model calls):** static-contract trigger tests under
   `tests/trigger/`, run by `scripts/ci.sh` on every commit. CI never needs live
   model access, preserving "green always".
2. **Real triggering — local/nightly:** `scripts/eval.sh` runs `claude -p` with
   positive + negative prompts, N runs, thresholds (pos ≥ 4/5, neg ≤ 1/5),
   grey-band quarantine. Proven: `extended-superpowers-overview` fired 3/3 on the
   positive prompt and 0/3 on the negative.

`promptfoo` / `cc-plugin-eval` are an **optional upgrade** for behavioural
rubrics beyond triggering (with a free judge model, per ADR-0002), added only
when a skill needs behavioural scoring. Don't add a heavy external dependency
before a skill needs it.

## Consequences

- CI stays fast and credential-free; real evals are a separate gate.
- The harness reuses one proven technique (E01), one fewer moving part.
- If behavioural rubrics become necessary, `promptfoo` is the upgrade path.
