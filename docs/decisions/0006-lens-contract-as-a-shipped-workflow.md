# ADR-0006 — The adversarial lens contract ships as a workflow, not only as prose

**Status:** accepted
**Date:** 2026-07-25
**Supersedes:** nothing. Extends ADR-0001 (companion, not fork).

## Context

`skills/adversarial-review/SKILL.md` declares its lens table "binding" and lists
"a single generic reviewer cannot stand in for the set" as a red flag. That is a
`for` loop enforced by an honour system: nothing prevents the set from quietly
shrinking to one reviewer, and the artifact still advances through the gate.

Claude Code gained *dynamic workflows* — deterministic multi-agent orchestration
driven by a JavaScript script — after this plugin was designed (2.1.154+).
Experiment **E02** established that a plugin can ship one: `workflows` is a
recognised manifest field, the component loader treats workflows as first-class,
and a `workflows/` directory at the plugin root survives marketplace install.
Plugin workflows are namespaced `/<plugin>:<meta.name>`.

## Decision

Ship the lens contract as `workflows/adversarial-review-gate.js`, invoked as
`/extended-superpowers:adversarial-review-gate`, and keep the skill's prose
protocol as the fallback path.

In the workflow the lens table is the loop bound rather than a suggestion.
Three properties that were advisory become structural:

- **Lens completeness.** The reviewer set is derived from the table, so dropping
  a lens requires editing the contract, not merely forgetting it. A lens that
  returns nothing is logged and forces NO-GO rather than passing silently.
- **Enumerate-only with graded findings.** Each reviewer returns schema-validated
  structured findings (severity, where, problem, fix) instead of free text that
  has to be parsed by eyeball.
- **The binding implementation order.** `spec-compliance` runs first, and
  `code-quality` is *not dispatched at all* while compliance is dirty — the
  skill's red flag becomes a short circuit.

The skill keeps the manual protocol, because workflows require 2.1.154+ and
because an artifact may need a lens set this table does not cover. Graceful
degradation, consistent with ADR-0005's "optional if installed" posture.

## Consequences

**CI must lint the workflow scripts, because the platform does not.** E02's
first surprise: a workflow script containing invalid JavaScript passed
`claude plugin validate` with zero warnings, installed cleanly, and left the
plugin `enabled`. A broken review gate would therefore validate green, install
green, and fail only when a user invoked it — the worst possible failure
location for a tool whose purpose is enforcing gates. `scripts/ci.sh` step 5
syntax-checks every shipped workflow and asserts each declares a `meta.name`.

A plain `node --check` is *not* sufficient and returns a false pass: workflow
scripts carry `export const meta` alongside top-level `await` and `return`, which
no single node parse mode accepts. The check de-exports and wraps the body in an
async function first. Verified RED on a planted syntax error, GREEN on the real
script.

**The DoD gate now covers workflows.** `acceptance_green` fails if a shipped
workflow has no contract test, exactly as it does for an untested skill.

**API surface is deliberately restricted.** E02's second surprise: the public
workflows documentation describes a strict subset of the runtime script API.
Shipped workflows use the documented core (`agent`, `pipeline`, `parallel`,
`schema`, `label`) plus `phase()`/`log()` (progress only — nothing load-bearing
depends on them) and `agentType` (required to dispatch the plugin's own bundled
reviewer agents rather than inlining copies of their briefs that would drift).
The `budget` global, nested `workflow()` and `resumeFromRunId` are avoided until
first-party docs cover them; the contract test fails the build if they appear.

## Release gate (open)

End-to-end invocation of a plugin-shipped workflow is **documented but not
observed**. Credentials do not follow `CLAUDE_CONFIG_DIR`, so the sandboxed probe
could not run it, and neither copying credentials into the sandbox nor installing
a probe into the real config was acceptable. This joins the standing
cross-machine install check as a one-time manual gate before the next tag — the
same shape as E01's residual caveat.

## Alternatives considered

- **Convert the whole seven-phase loop into one workflow.** Rejected: workflows
  take no mid-run user input and cannot hand off to superpowers' interactive
  brainstorming, which would break E01's validated ordering and remove the human
  from the loop between phases.
- **Replace the skill with the workflow.** Rejected: it would hard-require
  2.1.154+ and delete the escape hatch for artifacts needing a bespoke lens set.
- **Inline the reviewer briefs instead of using `agentType`.** Rejected: it
  duplicates the bundled agent definitions, which then drift.
