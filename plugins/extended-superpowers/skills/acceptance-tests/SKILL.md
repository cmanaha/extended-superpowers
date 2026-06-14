---
name: acceptance-tests
description: Use when you need to prove a feature or a skill actually delivers its intended OBSERVABLE outcome — deriving executable acceptance tests from a spec's success criteria (what the user sees, not just internal code paths), and, for skills, verifying they trigger when they should and stay silent when they should not; triggers at the "is it really done / does it really work" gate, before any definition-of-done claim.
---

# Acceptance Tests

Acceptance tests assert what the user observes (validation): "did we build the
right thing." Unit/integration tests assert code paths (verification): "did we
build it right." Both are needed; only the first catches a feature that was
specified but never actually wired.

## Deriving acceptance tests from a spec

For each **observable success criterion** in the spec, write a Given/When/Then
that asserts the user-visible outcome. If the spec says "the status bar shows
`ctx 127K (63%)`", the test asserts that string appears — not that a parse
function returns a number. (Pattern: integration tests tagged `SPEC:`.)

## Acceptance tests for skills (this plugin's case)

A skill's observable outcome is three things; test all three:

1. **Triggers on positives** — the skill fires on prompts it should handle.
2. **Stays silent on negatives** — it does NOT fire on unrelated prompts.
3. **Produces its artifact** — when followed, it yields the expected output
   (e.g. environment-research yields a `decisions.jsonl`).

### Two tiers (and where each runs)

- **Floor — CI-safe, no model calls:** the static-contract trigger tests under
  `tests/trigger/` (description contract, lens completeness, artifact presence).
  These run in `scripts/ci.sh` on every commit.
- **Real triggering — model calls, local/nightly:** `scripts/eval.sh` copies a
  skill into a throwaway project, runs `claude -p` with positive and negative
  prompts, and parses the transcript for the skill firing. This is the same
  headless technique proved in experiment E01.

### Non-determinism (mandatory)

Triggering is stochastic. Every real eval runs N times (default N=5) with
thresholds: positive-fire ≥ 4/5, negative-fire ≤ 1/5. A grey-band result (e.g.
3/5) **quarantines** the skill (the eval warns, never silently passes) until the
description is fixed. Tune descriptions with a skill-eval / description-tuning
tool (e.g. the `skill-creator` plugin), if available.

## Optional harness upgrade

For behavioural rubrics beyond triggering, `promptfoo` (its `skill-used`
assertion) or `cc-plugin-eval` can be added with a free judge model. The in-repo
headless eval is the floor; the external harness is an upgrade — see ADR-0004.

## Red flags — stop

- Asserting a code path and calling it acceptance.
- A single-run eval (no N, no threshold).
- A mock that hides the real observable outcome.
- A trigger eval with no negative prompt.
- Claiming "done" before the acceptance tests are green.
