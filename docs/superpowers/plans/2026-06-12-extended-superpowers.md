# extended-superpowers — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: use `superpowers:subagent-driven-development`
> (recommended) or `superpowers:executing-plans` to implement task-by-task.
> Author each skill with `superpowers:writing-skills`. Steps use checkbox
> (`- [ ]`) syntax for tracking.

**Goal:** Ship a companion plugin that extends superpowers with planning,
environment-research, named-lens adversarial review, an executable acceptance
tier, and a tooling-enforced definition of done — distributable from a public
marketplace.

**Architecture:** A marketplace repo hosting one plugin that declares a
dependency on superpowers. New phases are additive skills + agents + hooks;
superpowers skills are reused, never edited. See the spec and ADR-0001/2/3.

**Author:** Carlos Manzanedo Rueda. No AI attribution anywhere — enforced by the
committed `.githooks/commit-msg` (wired by `scripts/setup.sh`) AND a git-history
check in `scripts/ci.sh`, so the guard holds on a fresh clone and in CI.

> **Revision note:** v2 of this plan, hardened against a three-lens adversarial
> review (coverage+guardrails, testing+trackability, sequencing+anti-hubris).
> The fixes are inlined below and flagged `[rev]`.

---

## Cross-cutting requirements

- **Authorship:** every commit authored by Carlos Manzanedo Rueda; the guard is
  committed (setup.sh + ci.sh history check), not reliant on local git config. `[rev]`
- **Green always:** every commit keeps `claude plugin validate` and `ci.sh`
  passing. Any gate added to ci.sh lands in report-only mode first, is confirmed
  satisfied, then flipped to blocking in the same commit. `[rev]`
- **Reuse over rebuild:** depend on superpowers; only add what it lacks.
- **No push without instruction:** local commits only until explicitly told.

## Eval determinism & thresholds (applies to every skill eval) `[rev]`

Skill triggering and behavioural rubrics are stochastic. No eval is single-run.

- **Run count:** each trigger/behavioural eval runs N=5 times (chosen as the
  smallest N that distinguishes a ~60%-reliable skill from a ~90% one within CI
  time/cost; revisit with data via `threshold-reasoning`).
- **Pass thresholds:** positive-trigger rate ≥ 4/5; negative-trigger (false
  fire) rate ≤ 1/5. Behavioural recall: stated per skill with selection logic;
  default planted-flaw recall ≥ 4/5 over a fixture set of ≥ 5 items each with ≥ 1
  planted flaw.
- **Flake policy:** a result inside the grey band (e.g. 3/5) quarantines the
  skill (CI warns, not green-lies) until the description or skill is fixed; it is
  never silently passed.
- Every number above is provisional and re-derived once real data exists; the
  plan does not ship unjustified constants.

---

## Milestones (named — each is a shippable increment)

- Milestone 1 — Walking skeleton: an installable empty plugin. (built this session)
- Milestone 2 — Environment-research skill + the E01 architecture gate. **Cut v0.0.2 here.** `[rev]`
- Milestone 3 — Adversarial-review skill: the full named-lens contract.
- Milestone 4 — Acceptance-tests skill: real headless trigger evals + harness. **Cut v0.1.0 here.**
- Milestone 5 — Definition-of-Done gate: tooling-enforced completion.
- Milestone 6 — Planning-session + Orchestrator skills. **Cut v0.2.0 here.**

`[rev]` Releases re-cut smaller: the first tag (v0.0.2) ships only after the core
architecture assumption is *proven* (M2), not after four unproven skills.

---

## Milestone 1 — Walking skeleton (installable empty plugin)

**Status:** built and verified this session (`claude plugin validate` ✔, ci.sh
green, commit-msg guard rejects AI attribution).

- [x] Manifest validation passes; ci.sh green.
- [ ] **Manual one-time gates (NOT CI/regression)** `[rev]` — these require an
  interactive session and a human; they are a one-time smoke check, not a
  reproducible contract (the reproducible version arrives in M4 as headless
  tests): (a) `/plugin marketplace add ./` + `/plugin install extended-superpowers@manzanedo`
  installs and pulls superpowers; (b) "show me the extended superpowers loop"
  fires the overview skill; an unrelated prompt does not.
- [x] Authorship guard: hook rejects an AI-attributed message; ci.sh checks
  history. Verified this session.

## Milestone 2 — Environment-research skill + E01 architecture gate

**Files:** `.../skills/environment-research/SKILL.md`, `.../reference.md`
(harvest format), `docs/experiments/README.md` (disposable-tree contract),
`tests/eval/fixtures/` (committed RED baselines).

- [ ] **Step 1: RED baseline (committed)** `[rev]` — pressure scenario: an agent
  about to spec on an undocumented dependency. Run WITHOUT the skill; commit the
  scenario prompt + the without-skill outcome to `tests/eval/fixtures/env-research/`
  so RED→GREEN is later falsifiable.
- [ ] **Step 2: Write the skill** — hypotheses about a dependency's
  execution/outcome/error/boundary modes → isolated experiments under
  `docs/experiments/<probe>/scratch/` (gitignored) → `decisions.jsonl` + `Lessons.md`
  → keep/iterate/discard graduation → harvest findings into the brief.
- [ ] **Step 3: GREEN (observable delta, not a judgment call)** `[rev]` — WITH
  the skill, the run produces `docs/experiments/<probe>/decisions.jsonl`; WITHOUT
  it, no such file. Assert the file delta, not "it feels like it probed."
- [ ] **Step 4: E01 — the architecture GO/NO-GO gate** `[rev]` — use the skill to
  probe: *can an orchestrator skill sit before superpowers' brainstorming without
  overriding its handoff?* Harvest to `docs/experiments/E01-plugin-sequencing/`.
  **Kill criterion:** if superpowers' bootstrap/handoff overrides the inserted
  phase, STOP — do not start M3. Record the decision and switch to the ADR-0001
  "shadow exactly one skill" fallback, re-planning M6 before proceeding.
- [ ] **Step 5: Trigger evals** — positive ("probe this library before we
  design"), negative (a pure-docs question), N=5 per the determinism section;
  tune the description with `skill-creator`.
- [ ] **Step 6: Cut v0.0.2 (architecture-validated preview)** — only if E01 is
  GO. Bump, CHANGELOG, tag.
- [ ] **Step 7: Commit** — `feat: environment-research skill + E01 architecture gate`.

## Milestone 3 — Adversarial-review skill (full named-lens contract)

**Files:** `.../skills/adversarial-review/SKILL.md`, `.../agents/adversarial-reviewer.md`,
`tests/eval/fixtures/adversarial/` (specs/plans with planted flaws).

- [ ] **Step 1: RED baseline (committed)** — an agent reviewing its own artifact
  cooperatively misses a planted flaw; commit the fixture + baseline.
- [ ] **Step 2: Write the skill — encode the EXACT lens table** `[rev]`. The
  artifact→lens mapping is binding, from the spec:
  - spec: factual-grounding, completeness, design-flaw/race, testability/DoD;
  - plan: spec-coverage+guardrails, testing+trackability, sequencing+anti-hubris;
  - implementation: spec-compliance, then code-quality (both, in order).
  Dispatch each lens as a fresh `adversarial-reviewer` agent (separate from the
  author), "enumerate, don't fix", loop until clean. Reuse `staff-engineer-reviewer`
  and pr-review-toolkit agents; query Open Brain for the governing principle.
- [ ] **Step 3: GREEN** — planted flaws in sample spec+plan are found by the
  correct lenses; assert each artifact type dispatches its FULL named-lens set
  (a test counts the lenses, so a single generic reviewer cannot pass). `[rev]`
- [ ] **Step 4: Eval scope** `[rev]` — trigger evals only here (floor). The
  behavioural planted-flaw recall eval is deferred to M4 Step 3, where the harness
  exists; do not invent an ad-hoc harness in M3.
- [ ] **Step 5: Commit** — `feat: adversarial-review skill (full named-lens contract)`.

## Milestone 4 — Acceptance-tests skill (real headless evals + harness)

**Files:** `.../skills/acceptance-tests/SKILL.md`, `tests/eval/` harness +
config, `tests/trigger/` promoted to real headless tests.

- [ ] **Step 1: Harness — thin spike, default chosen** `[rev]` — default to
  `promptfoo`'s `skill-used` assertion unless the spike shows it cannot assert
  Skill calls against this plugin layout; fallback then is `cc-plugin-eval`; final
  fallback is "the dependency-free trigger floor IS the system." Record the
  outcome as an **addendum to ADR-0002** (not a new ADR). Constraint: free judge
  model (no Claude credits) per ADR-0002.
- [ ] **Step 2: Write the skill** — derive Given/When/Then acceptance tests from
  a spec's observable success criteria; for skills that means N-run
  positive/negative trigger evals + a behavioural rubric (determinism section).
- [ ] **Step 3: Promote placeholders → real headless tests** `[rev]` — replace the
  static-grep trigger tests with headless-session tests (`claude -p`, parse the
  transcript for the Skill firing) for overview, environment-research, and
  adversarial-review. Backfill the M3 behavioural recall eval here.
- [ ] **Step 4: Wire CI as a red-state, not prose** `[rev]` — ci.sh fails if a
  shipped skill has no real (non-placeholder) trigger test; the harness runs
  score-gated on push to skills paths + nightly; CI prints the test tier.
- [ ] **Step 5: Cut v0.1.0** — bump, CHANGELOG, tag. Verify on a second machine
  that the two install commands exit 0, the skills are listed, AND superpowers
  resolved via the declared dependency (not a pre-existing install). Author the
  ADR-0001 install-fallback doc (managed-settings / shadow-one-skill). `[rev]`
- [ ] **Step 6: Commit** — `feat: acceptance-tests skill + real evals; release v0.1.0`.

## Milestone 5 — Definition-of-Done gate (tooling-enforced)

**Files:** `.../skills/definition-of-done/SKILL.md`, `.../hooks/definition-of-done.sh`,
`dod.config` schema.

- [ ] **Step 1: Write the gate with conditional criteria** `[rev]` — `dod.config`
  declares each criterion as `required | n/a` per project: grooming, CI green,
  lint clean, coverage floor (`n/a` for a markdown/bash repo like this one),
  telemetry corroboration (`n/a` unless a concrete telemetry source is named —
  it is advisory, never a hard gate on a vague "where applicable"), acceptance-
  green. GO/NO-GO; any required NO-GO fails all.
- [ ] **Step 2: Write the skill** — assembles the per-project config and runs the
  gate before any "done" claim.
- [ ] **Step 3: Self-host (report-only → blocking)** `[rev]` — add the gate to
  this repo's ci.sh in report-only mode, confirm every required criterion already
  passes, then flip to blocking in the same commit (preserves "green always").
- [ ] **Step 4: Test the block with a real criterion** `[rev]` — force CI red
  (e.g. break a JSON manifest) and confirm the gate NO-GOs; restore and confirm
  GO. Do not test via coverage (n/a here).
- [ ] **Step 5: Commit** — `feat: definition-of-done gate (tooling-enforced)`.

## Milestone 6 — Planning-session + Orchestrator skills

**Files:** `.../skills/planning-session/SKILL.md`, `.../skills/orchestrator/SKILL.md`,
`.../agents/research-scout.md`.

- [ ] **Step 1: planning-session skill** — bounded/budgeted research via
  `research-scout` agents; brief-as-hypothesis; cross-check every load-bearing
  claim against the primary source; output in the doc taxonomy.
- [ ] **Step 2: orchestrator skill** — sequence phases 1-7, delegating to
  superpowers. Built on the E01 (M2) GO result. **If E01 was NO-GO**, implement
  the ADR-0001 shadow-one-skill fallback instead of a pre-brainstorm orchestrator. `[rev]`
- [ ] **Step 3: Wire the DoD gate INTO phase 7** `[rev]` — the orchestrator's
  phase-7 step calls `definition-of-done.sh` and refuses to emit a completion
  claim on NO-GO. Add an acceptance test for spec success criterion #4 ("the gate
  blocks a 'done' claim when any criterion fails").
- [ ] **Step 4: Full-loop dogfood** — run the entire loop on a small real
  feature; confirm each gate engages.
- [ ] **Step 5: Cut v0.2.0** — bump, CHANGELOG, tag; verify clean install.
- [ ] **Step 6: Commit** — `feat: planning-session + orchestrator; release v0.2.0`.

---

## Self-review (run before adversarial review — done; this is v2)

1. Spec coverage: every spec component + success criterion maps to a task
   (criterion #4 now wired in M6 Step 3; #1 dependency-resolution in M4 Step 5).
2. Placeholder scan: no TBD/TODO in shipped skills; placeholder trigger tests are
   a CI red-state once M4 lands, not a silent pass.
3. Naming consistency: skill names match across spec, plan, manifests.
4. Numbers: every threshold carries selection logic or is explicitly deferred to
   `threshold-reasoning` (determinism section).
