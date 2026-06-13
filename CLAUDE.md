# extended-superpowers — Project Rules (Claude Code)

Read `AGENTS.md` for the cross-tool conventions and non-negotiables. This file
adds Claude-Code-specific guidance.

## Hard rules (repeat of the non-negotiables)

- Author is **Carlos Manzanedo Rueda**. No AI attribution anywhere — enforced by
  `.githooks/commit-msg`.
- Keep `claude plugin validate ./plugins/extended-superpowers` and
  `scripts/ci.sh` green on every commit.
- Local commits are fine during development; **do not push or create the GitHub
  remote without explicit instruction.**

## Dogfooding

This plugin is built using its own methodology. Use `superpowers` skills for
brainstorming / writing-plans / subagent-driven-development, and apply this
repo's own phases as they come online: environment-research to probe the plugin
platform, adversarial-review at each gate, acceptance tests for skill triggering,
and the definition-of-done gate before any "done" claim.

## Building skills

- Author and test skills with `superpowers:writing-skills` (RED baseline →
  GREEN skill → REFACTOR) and tune triggering with the `skill-creator` eval
  scripts before shipping.
- A skill's `description` field is the trigger contract — start it with
  "Use when …" and describe triggering conditions only, not the workflow.

## Plan mode

Investigation/planning tasks produce a plan for approval — no code changes until
approved. A hypothesis is validated by gathering data, not by speculative edits.
