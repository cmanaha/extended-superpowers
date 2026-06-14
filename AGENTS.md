# extended-superpowers — Cross-Tool Conventions

For any AI-powered tool (Claude Code, Cursor, Kiro, etc.) working in this repo.

## Non-Negotiables (enforced, not advisory)

- **No AI attribution.** Commits are authored by humans. No `Co-Authored-By` (AI),
  no "Generated with" footers, no 🤖 lines, no AI-tool attribution of any kind —
  in commits, PRs, or files. Enforced by `.githooks/commit-msg` and a git-history
  check in `scripts/ci.sh`; do not bypass. (Authorship and copyright metadata
  live in `LICENSE` and the plugin manifests, not in the guard.)
- **Never commit or print secrets.** No tokens, keys, or credentials. Test data uses
  fakes only.
- **The repo must stay installable.** Every commit leaves
  `claude plugin validate ./plugins/extended-superpowers` passing and
  `scripts/ci.sh` green.

## What this plugin is

A companion plugin that depends on `superpowers` and adds a prelude: planning-session,
environment-research, to use before superpowers/brainstorm and then add named-lens adversarial review, 
for spec and plan phases together with an executable acceptance
tier, and a tooling-enforced definition of done. The plugin sequences its own phases around superpowers' skills.

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
- ADR-first: research → decision → code, never reversed, reviewed and preserved and 
  marked obsolete if something superseeds the decision
- Reuse superpowers; only add what this additions. Do pragmatic engieering do not boil the ocean.
