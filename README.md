# extended-superpowers

[![ci](https://github.com/cmanaha/extended-superpowers/actions/workflows/ci.yml/badge.svg)](https://github.com/cmanaha/extended-superpowers/actions/workflows/ci.yml)

**Docs & the flywheel loop → https://cmanaha.github.io/extended-superpowers/**

A research-first, adversarially-reviewed, acceptance-gated development loop for
Claude Code, built as a companion plugin on top of
[superpowers](https://github.com/obra/superpowers).

It does not fork or replace superpowers. It depends on it, reuses its
brainstorming / writing-plans / subagent-driven-development / TDD skills, and
adds the phases superpowers leaves to the human:

1. **Planning session** — bounded, budgeted research before brainstorming; the
   brief is a starting vector, every load-bearing claim is checked against the
   primary source.
2. **Environment research** — empirically probe a dependency by *running* it in
   small, isolated, disposable experiments; harvest the findings into the spec.
3. **Adversarial review** — named-lens, separate-from-author review at the spec,
   plan, and implementation gates.
4. **Acceptance tests** — executable, observable-outcome tests (what the user
   sees), with skill-trigger evals folded in.
5. **Definition of done** — a tooling-enforced gate (grooming, CI, lint,
   coverage, telemetry, acceptance-green), not advisory prose.

## Install

In Claude Code, from any machine:

```
/plugin marketplace add cmanaha/extended-superpowers
/plugin install extended-superpowers@cmanaha
```

`superpowers` is a declared dependency and resolves automatically. Restart
Claude Code after installing.

## Develop

After cloning, run the one-time setup so the authorship guard is active on your
clone:

```
bash scripts/setup.sh
```

Then `bash scripts/ci.sh` runs the full quality spine (manifest validation, JSON
+ shell lint, skill front-matter, trigger tests, and a git-history authorship
check). CI runs the same script.

## Status

Early development. See `docs/superpowers/specs/` for the design and
`docs/superpowers/plans/` for the implementation plan. Decisions are recorded in
`docs/decisions/`.

## License

MIT © 2026 Carlos Manzanedo Rueda
