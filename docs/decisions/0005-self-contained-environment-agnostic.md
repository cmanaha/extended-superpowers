# ADR-0005: Self-contained and environment-agnostic

**Date:** 2026-06-14
**Status:** Accepted

## Context

The plugin must run identically on any machine (principle 1 — isolated &
shareable). A review found the two richest skills referenced components that
exist only in the author's personal setup and would be absent on a clean install:
a personal memory MCP, a personal
`staff-engineer-reviewer` agent, and a personal `threshold-reasoning` skill.
That broke the isolation principle exactly where it mattered most.

## Decision

- **Self-contained loop:** the plugin bundles its own review agents —
  `adversarial-reviewer` (single-lens), `spec-compliance-reviewer` and
  `code-quality-reviewer` (the two implementation lenses), and `research-scout`.
  The loop never depends on an agent that isn't shipped here.
- **External tools are optional enhancements only.** Public plugins like
  `pr-review-toolkit` and `skill-creator`, and any personal specialists, are
  referenced as "if installed" — never as the default path.
- **Memory is generic.** Skills read/write a generic "memory" (a `memory` MCP
  server or a project principles doc) *if available*, with an explicit inline
  fallback when it is absent. No personal MCP is named.
- **Author metadata is retained.** "Carlos Manzanedo Rueda" in LICENSE and the
  manifests is ownership, not environment, and stays.

## Consequences

- A clean install is never told to use a component it does not have; the plugin
  behaves the same for everyone.
- Acceptance check: zero references to the personal memory MCP anywhere, and no
  *required* use of a personal agent/skill in shipped files (this ADR and the
  de-identification plan are records and are excluded).
- Richer specialists still enhance the loop when present — reuse over rebuild.
