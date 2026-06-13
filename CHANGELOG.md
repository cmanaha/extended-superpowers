# Changelog

All notable changes to this project are documented here. This project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

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
