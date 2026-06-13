# extended-superpowers — Cross-Tool Conventions

For any AI-powered tool (Claude Code, Cursor, Kiro, etc.) working in this repo.

## Non-Negotiables (enforced, not advisory)

- **Author is Carlos Manzanedo Rueda.** No `Co-Authored-By` lines, no "Generated
  with" footers, no AI attribution of any kind — in commits, PRs, or files. This
  is enforced by the `.githooks/commit-msg` hook; do not bypass it.
- **Never commit secrets.** No tokens, keys, or credentials. Test data uses
  fakes only.
- **The repo must stay installable.** Every commit leaves
  `claude plugin validate ./plugins/extended-superpowers` passing and
  `scripts/ci.sh` green.

## What this plugin is

A companion plugin that depends on `superpowers` and adds: planning-session,
environment-research, named-lens adversarial review, an executable acceptance
tier, and a tooling-enforced definition of done. It never forks or edits
superpowers; it sequences its own phases around superpowers' skills.

## Document taxonomy (do not conflate)

- `docs/superpowers/specs/` — the source-of-truth design.
- `docs/superpowers/plans/` — bite-sized implementation plans.
- `docs/decisions/` — ADRs; settled, do not re-debate.
- `docs/experiments/` — environment-research harvest: findings kept, experiment
  code disposable (gitignored scratch).

## Definition of Done

No change is "done" until `scripts/ci.sh` is green, the affected skills pass
their trigger/acceptance tests, and — once shipped — the definition-of-done gate
passes. The model cannot self-certify; tooling certifies.

## Engineering discipline

- Atomic, buildable commits; conventional-commit messages.
- ADR-first: research → decision → code, never reversed.
- Reuse superpowers; only add what it lacks. Do not boil the ocean.
