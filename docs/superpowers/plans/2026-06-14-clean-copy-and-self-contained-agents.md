# Clean Copy + Self-Contained Agents — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: use `superpowers:subagent-driven-development`
> or `superpowers:executing-plans`. Author skills/agents with
> `superpowers:writing-skills`. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Make extended-superpowers a fully self-contained, environment-agnostic
clean copy — no references to any personal setup — and give it its own review
agents so the loop runs the same on any machine. Plus small polish.

**Why:** The balanced review found the plugin adheres to 7 of its 8 principles;
the one it bends is **isolated & shareable** (principle 1): the two richest
skills reference things that do not exist on a clean install. This plan closes
that gap.

**Keep (NOT environment — intended ownership):** author/copyright metadata
"Carlos Manzanedo Rueda" in LICENSE and the manifests stays. Only references to a
personal *environment* (agents, skills, MCP servers) are removed/generalised.

---

## The generic mapping (de-identification rules)

| Personal reference (remove) | Generic replacement |
|-----------------------------|---------------------|
| a personal memory MCP | generic "memory" — the project's memory store (a `memory` MCP server or a project principles doc), used if available |
| `staff-engineer-reviewer` (personal agent) | this plugin's own bundled agents; external specialists optional "if installed" |
| `pr-review-toolkit` + sub-agents | optional enhancement "if the pr-review-toolkit plugin is installed" |
| `threshold-reasoning` (personal skill) | generic instruction: "justify any bare constant with its selection logic" (a threshold-reasoning skill, if installed, helps) |
| `skill-creator` | "a skill-eval / description-tuning tool (e.g. the skill-creator plugin), if available" |

Rule: a clean install must never be told to use a component it does not have.
External tools may only be referenced as **optional enhancements**, never as the
default path.

---

## Task 1 — Generic memory + optional external references (de-identify)

**Files:** `skills/adversarial-review/SKILL.md`, `skills/orchestrator/SKILL.md`,
`skills/acceptance-tests/SKILL.md`, `docs/superpowers/specs/2026-06-12-...md`,
any ADR/doc that names personal infra.

- [ ] **Step 1: Full leakage grep** — `grep -rIn -iE 'open[- ]brain|staff-engineer-reviewer|pr-review-toolkit|threshold-reasoning|silent-failure-hunter|type-design-analyzer|pr-test-analyzer|skill-creator'` across the WHOLE repo (not just plugins/). Record every hit.
- [ ] **Step 2: Apply the mapping** — for each hit, replace per the table above.
  the personal memory MCP → "memory" (save-to-memory / read-from-memory, if a memory store
  is available). Personal agents/skills → optional-if-installed, with the
  plugin's own agents as the default.
- [ ] **Step 3: Re-scan** — the same grep returns ZERO hard references (only
  optional/generic mentions remain). This is the acceptance check for Task 1.
- [ ] **Step 4: Commit** — `chore: make the plugin environment-agnostic (generic memory; optional external tools)`.

## Task 2 — Bundled review agents (self-contained loop)

**Files:** create `agents/spec-compliance-reviewer.md`,
`agents/code-quality-reviewer.md`; update `skills/adversarial-review/SKILL.md`
and `skills/orchestrator/SKILL.md`.

- [ ] **Step 1: spec-compliance-reviewer agent** — fresh-eyes, enumerate-only;
  audits whether the implementation matches the spec ("did you build what was
  specified" — missing/extra). Tools: Read, Grep, Glob, Bash.
- [ ] **Step 2: code-quality-reviewer agent** — fresh-eyes, enumerate-only;
  audits correctness/quality ("did you build it right" — bugs, drift, edge
  cases). Tools: Read, Grep, Glob, Bash.
- [ ] **Step 3: Rewire the lens contract** — implementation lenses dispatch the
  bundled `spec-compliance-reviewer` then `code-quality-reviewer` by default;
  external specialists (pr-review-toolkit) are optional add-ons. The spec/plan
  lenses keep using the generic `adversarial-reviewer`.
- [ ] **Step 4: Contract test** — extend `tests/trigger/adversarial-review.trigger.sh`
  to assert the two bundled impl-reviewer agents exist and are enumerate-only.
- [ ] **Step 5: Balanced GREEN demo** — dispatch `spec-compliance-reviewer` on a
  small sample (spec + an implementation that omits one spec item); confirm it
  reports the omission. Record briefly.
- [ ] **Step 6: Commit** — `feat: bundled spec-compliance + code-quality reviewer agents (self-contained loop)`.

## Task 3 — Polish

**Files:** `README.md`, `docs/superpowers/specs/...md`, `docs/decisions/0005-...md`,
optionally `plugins/extended-superpowers/commands/`.

- [ ] **Step 1: CI badge** — add the GitHub Actions status badge to the README.
- [ ] **Step 2: Reconcile spec wording** — success-criterion #3 says "trigger
  evals green in CI", but CI runs static-contract trigger tests; headless evals
  run local/nightly (ADR-0004). Fix the wording to match.
- [ ] **Step 3: ADR-0005** — record the decision: "self-contained &
  environment-agnostic — the plugin bundles its own agents and references
  external tools only as optional enhancements; memory is generic."
- [ ] **Step 4 (optional): two thin slash commands** — `/extended-superpowers:review`
  (invoke adversarial-review on an artifact) and `/extended-superpowers:dod`
  (run the definition-of-done gate). Defer `/docs` to the flywheel task.
- [ ] **Step 5: Commit** — `docs+chore: CI badge, spec wording, ADR-0005, optional commands`.

## Task 4 — Verify & ship

- [ ] **Step 1: Leakage = 0** — the Task 1 grep returns zero hard personal refs
  repo-wide.
- [ ] **Step 2: Green** — `scripts/ci.sh` green, shellcheck clean, all trigger
  tests pass, the definition-of-done gate returns GO.
- [ ] **Step 3: Push + CI** — push to main; confirm GitHub Actions is green.

---

## Review folded (v2)

Two balanced plan reviews adjusted the approach:
- **Public vs personal:** `skill-creator` and `pr-review-toolkit` are PUBLIC
  plugins — keep as optional "if installed" references. Only the personal memory MCP,
  `staff-engineer-reviewer` (personal agent), and
  `threshold-reasoning` (personal skill) are personal and must be removed/generalised.
- **Leakage acceptance is scoped, not repo-wide:** "zero hard personal refs" =
  zero `open-brain` anywhere, and zero required use of `staff-engineer-reviewer`/
  `threshold-reasoning` in LIVE shipped files (plugins/, CLAUDE.md, current spec,
  ADRs). Historical plans and this de-identification plan/ADR-0005 are records and
  are excluded from the zero-check.
- **memory needs a fallback clause:** "if a memory store is available, look up the
  principle and pass it in; otherwise state the principle inline from the artifact."
- Full agent paths (`plugins/extended-superpowers/agents/...`); name the
  orchestrator line-40 edit explicitly; the GREEN demo gets a RED pair (a matching
  impl where the reviewer reports zero gaps), samples ephemeral.

## Cross-cutting requirements

- Author/copyright metadata "Carlos Manzanedo Rueda" preserved (it is ownership,
  not environment). No AI attribution (guard enforced).
- Green always; no fork; reuse over rebuild; don't boil the ocean (external tools
  optional, not re-implemented).

## Self-review (adherence to the 8 principles)

1. **Isolated & shareable** — the explicit target; Task 1 + Task 2 close it.
   Acceptance = the leakage grep returns zero.
2. **Build on what exists** — bundled agents are minimal; external specialists
   reused-if-present, not re-implemented.
3. **Tooling-enforced** — unchanged; DoD gate still certifies.
4. **Dual-audience / taxonomy** — ADR-0005 records the decision (decision, not note).
5. **Three-tier testing / DoD** — contract test for the new agents; DoD GO.
6. **Adversarial verification** — preserved; now self-contained.
7. **Empirical** — Task 2 Step 5 demonstrates the new agent (run, don't assume).
8. **Pristine & ownable** — author preserved, zero AI attribution, green.
