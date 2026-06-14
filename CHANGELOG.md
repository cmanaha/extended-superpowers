# Changelog

All notable changes to this project are documented here. This project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- `adversarial-review` skill with the binding 9-lens contract (spec:
  factual-grounding, completeness, design-flaw/race, testability/DoD; plan:
  spec-coverage+guardrails, testing+trackability, sequencing+anti-hubris;
  implementation: spec-compliance then code-quality), plus the
  `adversarial-reviewer` agent (enumerate-only, one lens each).
- Lens-completeness CI test — a single generic reviewer cannot stand in for the
  full named-lens set.
- Verified GREEN: given only the spec body, the design-flaw/race lens
  independently finds the planted BLOCKER (an unwritten reconnect cursor) that a
  cooperative self-review marks "ready".

## [0.0.2] — 2026-06-13 — Architecture-validated preview

### Added
- `environment-research` skill (empirical probe phase) with its harvest-format
  reference and the disposable-tree contract under `docs/experiments/`.
- Experiment **E01 (plugin sequencing): GO** — a pre-brainstorm phase runs before
  superpowers' brainstorming (5/5 with hook-asserted ordering; 0/3 without). The
  prepend architecture is validated; Milestone 3 unblocked.
- SessionStart hook now asserts the loop ordering imperatively (the E01 lesson:
  ordering must be hook-enforced, not left to skill descriptions).

## [0.0.1] — Walking skeleton

### Added
- Walking skeleton: marketplace + plugin manifests, the
  `extended-superpowers-overview` skill, SessionStart bootstrap hook, CI spine
  (`scripts/ci.sh` + GitHub Actions), and the commit-msg authorship guard.
- Design spec and implementation plan under `docs/superpowers/`.
- ADR-0001 (companion, not fork), ADR-0002 (evals fold into the acceptance
  tier), ADR-0003 (SessionStart hook for activation reliability).
- Authorship enforcement on any clone: `scripts/setup.sh` wires the commit-msg
  guard, and `scripts/ci.sh` re-checks git history (so a fresh clone cannot
  introduce AI attribution even without local hook config).
- Implementation plan hardened via a three-lens adversarial review
  (coverage+guardrails, testing+trackability, sequencing+anti-hubris).
