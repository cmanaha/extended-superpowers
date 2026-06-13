# ADR-0001: Companion plugin, not a fork of superpowers

**Date:** 2026-06-12
**Status:** Accepted

## Context

We want a reusable, shareable development loop that extends superpowers with
phases it lacks (planning, environment-research, adversarial review, an
executable acceptance tier, a tooling-enforced definition of done). Two options:
fork superpowers and edit its skills, or build a separate companion plugin that
depends on it.

superpowers (v5.1.0) is actively developed and its maintainers explicitly state
their behaviour-shaping skill content is tuned and reject restructuring. Our
additions are purely additive — they prepend phases before brainstorming and
attach reviews at superpowers' existing review seams; they do not require editing
any superpowers skill.

Claude Code supports first-class plugin dependencies: `plugin.json` accepts a
`dependencies` array, and a marketplace can permit cross-marketplace
dependencies via `allowCrossMarketplaceDependenciesOn`.

## Decision

Build a separate companion plugin that declares
`dependencies: [{ "name": "superpowers", "marketplace": "claude-plugins-official" }]`.
Distribute it from this repo, which is also its own marketplace. Never fork or
edit superpowers.

## Consequences

- Zero merge tax against superpowers releases; our deltas are independently
  versioned and shareable in isolation.
- We must pin a marketplace id (`claude-plugins-official`) for the dependency and
  document an install fallback for locked-down machines (managed settings that
  restrict marketplaces).
- If a superpowers internal handoff ever blocks an inserted phase, the fallback
  is shadowing exactly one skill — never a full fork.
