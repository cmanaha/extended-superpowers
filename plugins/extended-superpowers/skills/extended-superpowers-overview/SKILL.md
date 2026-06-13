---
name: extended-superpowers-overview
description: Use when the user asks to see, explain, or summarize the extended-superpowers development loop, its phases, or how this plugin extends superpowers — surfaces the end-to-end loop and where each phase sits relative to superpowers.
---

# Extended Superpowers — The Loop

This plugin layers a research-first, adversarially-reviewed, acceptance-gated
loop on top of the `superpowers` plugin. It does not replace superpowers — it
sequences its own phases around superpowers' brainstorming, writing-plans, and
subagent-driven-development.

## The loop, end to end

1. Planning session — bounded, budgeted research before brainstorming. The
   research brief is a starting vector, not ground truth: every load-bearing
   claim is cross-checked against the primary source.
2. Environment research — empirically probe a dependency by running it. Small
   isolated throwaway experiments in a disposable tree discover real
   error/execution/boundary behaviour; findings are harvested into the brief.
3. Brainstorming (superpowers) → spec — followed by adversarial spec review.
4. Writing-plans (superpowers) → plan — followed by adversarial plan review.
5. Subagent-driven-development (superpowers) → code — with adversarial
   implementation review at the existing spec/quality review seams.
6. Acceptance tests — executable, observable-outcome tests (the user-visible
   behaviour, not just internal code paths). Skill evals fold in here.
7. Definition of done — a tooling-enforced gate: grooming, CI, lint, coverage,
   telemetry corroboration, and acceptance-green. Not advisory prose.

## Ownership

- New phases owned by this plugin: planning session, environment research,
  named-lens adversarial review, executable acceptance tier, definition-of-done
  gate, and the orchestrator that sequences them.
- Reused from superpowers (a declared dependency): brainstorming, writing-plans,
  subagent-driven-development, test-driven-development, verification-before-completion.

This overview skill is the walking skeleton: if it triggers, the plugin is
installed and wired correctly.
