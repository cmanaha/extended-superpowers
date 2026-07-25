# E02 — Can this plugin ship a workflow?

**Status:** GO with one residual gate — see Lessons.md
**Gate:** blocks converting any phase to a workflow. Do not write a workflow
script into `plugins/extended-superpowers/workflows/` until this resolves GO.

## The design question

Claude Code gained *dynamic workflows* (deterministic multi-agent orchestration
driven by a JavaScript script) after this plugin was designed. Three of the
plugin's phases are deterministic fan-out currently expressed as prose the model
is trusted to follow — most sharply `adversarial-review`, whose own SKILL.md
says the lens set is "binding" and lists "a single generic reviewer cannot stand
in for the set" as a red flag. That is a `for` loop enforced by an honour system.

A workflow makes that loop structural. But the whole approach depends on a
distribution question: **can a plugin ship a workflow at all**, or are workflows
only a user/project-level artifact under `.claude/workflows/`? If plugins cannot
ship them, the conversion is impossible without asking every user to hand-install
a script, and the design stops here.

## Hypotheses

1. `workflows` is a recognised `plugin.json` manifest field, not an ignored key.
2. The component loader treats workflows as a first-class plugin component.
3. A `workflows/` directory at the plugin root survives marketplace install.
4. *(error mode)* A syntactically broken workflow script fails validate/install.
5. *(outcome mode)* The shipped workflow is invocable as `/<plugin>:<meta.name>`.
6. *(outcome mode)* The script API is limited to the documented
   `agent()`/`pipeline()`/`parallel()`.

## Method

Disposable harness under `scratch/` (gitignored). A throwaway marketplace and
plugin carrying two workflow scripts — one valid, one deliberately broken —
installed into a **sandboxed `CLAUDE_CONFIG_DIR`** so the real config is never
touched. The filename (`file-name-differs.js`) is deliberately different from
`meta.name` (`probe-flow`) so the naming rule is observable rather than assumed.

A control arm plants a `bogusComponentKey` in the manifest: without it, a silent
validator says nothing about whether `workflows` was *recognised* or merely
*ignored*.

## Kill criterion

If `workflows` is an ignored unknown key, or the directory does not reach the
plugin cache on install, the conversion is NO-GO and `adversarial-review` stays
a prose skill.
