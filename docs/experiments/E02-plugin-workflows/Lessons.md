# E02-plugin-workflows — Lessons

## What we set out to learn

Whether this plugin can *ship* a workflow — the distribution question that gates
converting any deterministic-fan-out phase (`adversarial-review` first) from
prose into a script. If plugins cannot carry workflows, the conversion dies here.

## What we observed

`workflows` is a real plugin component, confirmed three independent ways:

1. **Manifest field.** `claude plugin validate` accepted a manifest carrying
   `workflows` in silence, while flagging a planted `bogusComponentKey` as
   "Unknown field ... Claude Code ignores it at load time". The validator
   discriminates, so the silence is a positive result, not indifference. The
   control arm is what makes this line evidence instead of a guess.
2. **Component loader.** The installed 2.1.219 binary enumerates exactly
   `["commands","agents","output-styles","skills","workflows","routines"]` and
   carries manifest handling for `a.workflows` plus a resolved `workflowsPath`
   joined to the plugin root.
3. **Install.** After a sandboxed `marketplace add` + `plugin install`, both
   scripts were present under
   `config/plugins/cache/probe-mp/probe-plugin/0.0.1/workflows/`.

Documented naming rule (first-party, `code.claude.com/docs/en/workflows`): a
plugin `acme-tools` shipping a script whose `meta.name` is `release-audit` runs
as `/acme-tools:release-audit`. Plugin workflows are namespaced by plugin name.

## Surprises (predicted != observed)

**Two, and both change the design.**

**1. A broken workflow script is caught by nothing.** `workflows/broken.js`
containing invalid JavaScript and a malformed `meta` literal passed
`claude plugin validate` with *zero* warnings, installed cleanly, and left the
plugin `enabled`. Neither validate nor install parses workflow scripts.

This is the E02 equivalent of E01's precedence lesson: an assumption that the
platform would catch our mistake, refuted by running it. It means **the plugin's
own CI must lint its workflow scripts**, because the platform will not. Shipping
a workflow with a syntax error would produce a plugin that validates green,
installs green, and fails only when a user invokes the review gate — the worst
possible failure location for a tool whose entire purpose is enforcing gates.

**2. The public docs describe a strict subset of the script API.** The
`workflows` doc page shows `agent()`, `pipeline()`, `parallel()`. The 2.1.219
runtime additionally exposes `phase()`, `log()`, a `budget` global
(`total`/`spent()`/`remaining()`), `workflow()` nesting, `resumeFromRunId`, and
`agent()` options for `schema`, `label`, `model`, `effort`, `isolation` and
`agentType`. Building on the undocumented surface is a deliberate risk, not an
oversight. This plugin's workflows are therefore restricted to the documented
core (`agent()`, `pipeline()`, `parallel()`, `schema`, `label`) plus exactly
three additions, each with a stated reason:

- `phase()` and `log()` — progress reporting only. If they ever vanish the
  review still runs; nothing load-bearing depends on them.
- `agentType` — **required**, not cosmetic: without it the workflow cannot
  dispatch the plugin's own bundled reviewer agents and would have to inline
  duplicate copies of their briefs, which then drift from the agent definitions.

Explicitly avoided until first-party docs cover them: the `budget` global,
nested `workflow()`, and `resumeFromRunId`.

## Unverified — carried as a release gate

End-to-end invocation (`/extended-superpowers:<name>` actually running) is
**not** observed. Invocation inside the sandboxed `CLAUDE_CONFIG_DIR` returned
"Not logged in": credentials do not follow `CLAUDE_CONFIG_DIR`. Closing it would
require copying credentials into the sandbox or installing the probe into the
real config — both rejected. The naming rule is documented-only.

This is the same shape as E01's residual caveat and the standing cross-machine
install gate: a one-time manual check by a human with a logged-in session, not a
blocker on the build. Recorded in the release gates, not hand-waved.

## Graduation decision

**keep** — the distribution question resolves GO, and the two surprises produce
concrete design constraints (CI must lint workflow scripts; restrict to the
documented API subset) that would otherwise have shipped as latent defects.

## Findings to embed in the brief/spec

- Plugins ship workflows from `workflows/` at the plugin root; namespaced
  `/<plugin>:<meta.name>`; `meta.name` names the command, not the filename.
  (decisions.jsonl lines 1-3, plus first-party docs for the naming rule.)
- **CI must syntax-check every shipped workflow script.** The platform checks
  nothing — validate and install both pass a broken script. (line 4, `matched:false`)
- Restrict shipped workflows to the documented API subset plus
  `phase()`/`log()`/`schema`; do not depend on `budget`, nested `workflow()` or
  `resumeFromRunId` while they remain undocumented. (line 6, `matched:false`)
- End-to-end invocation is a manual release gate, not a CI check. (line 5)
