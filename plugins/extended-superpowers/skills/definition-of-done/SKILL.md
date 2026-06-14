---
name: definition-of-done
description: Use when about to claim work is complete, done, shippable, or ready to release or tag a milestone — runs the tooling-enforced Definition-of-Done gate instead of asserting completion from memory; triggers on "is this done?", "ready to ship/release", "close this out", or before any completion claim.
---

# Definition of Done

A Definition of Done is an eval, not a checklist to remember. Compliance with a
remembered checklist decays over a long session; a script that gates completion
cannot be skipped. **The model cannot self-certify "done" — the tooling certifies
it.**

## How it works

The gate is `plugins/extended-superpowers/hooks/definition-of-done.sh`. It reads a
per-project `dod.config` that declares each criterion as `required` or `n/a`,
runs every required check, and emits GO / NO-GO. Any required NO-GO fails the
whole gate.

```
plugins/extended-superpowers/hooks/definition-of-done.sh dod.config
```

## Criteria (conditional per project)

- `ci_green` — the project's CI spine passes.
- `grooming` — no placeholders/leftovers in shipped artifacts; docs current.
- `acceptance_green` — the acceptance tests pass (e.g. every shipped skill has a
  trigger test).
- `coverage`, `lint`, `telemetry` — declare `required` with a defined check, or
  `n/a`. Never gate on a criterion the tooling cannot actually evaluate (a vague
  "where applicable" is not a gate).

## Using it

1. Assemble/confirm the project's `dod.config` (what actually applies here).
2. Run the gate before claiming done or cutting a release.
3. On NO-GO: fix the failing criterion and re-run. Do not claim done on NO-GO.

It wraps the CI spine (`scripts/ci.sh`) rather than being embedded inside it, so
there is no recursion and CI stays fast and credential-free.

## Red flags — stop

- Saying "done" / "shipped" without running the gate.
- Marking a criterion `required` with no real check behind it.
- Editing the config to pass instead of fixing the failure.
