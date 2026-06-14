---
name: planning-session
description: Use when starting a non-trivial piece of work that needs research before design — runs a bounded, budgeted research phase (parallel research-scout agents) and produces a research brief whose every load-bearing claim is cross-checked against the primary source; precedes brainstorming. Triggers on "research X before we build", "plan this out first", or the start of a build/create request before any design.
---

# Planning Session

The research phase that comes before brainstorming. It produces a brief — and a
brief built from documentation is a hypothesis, not ground truth.

## Core principles

- **Research before brainstorming.** Brainstorming is much cheaper and sharper
  when the intent and constraints are already understood.
- **Bounded and budgeted.** Dispatch `research-scout` agents with an explicit
  scope and token budget so the fan-out converges instead of sprawling. More
  scouts on a wide question; fewer on a narrow one.
- **The brief is a hypothesis.** Every load-bearing claim must be cross-checked
  against the primary source before it enters the brief. Agents correct claims
  silently against the source rather than parroting the brief.
- **Classify by source authority.** Primary/first-party outranks secondary/press
  outranks speculation. Label tiers; never launder a secondary number as primary.

## Process

1. Frame the question and the decisions the brief must inform.
2. Dispatch `research-scout` agents in parallel, each on a narrow sub-question
   with a budget.
3. Synthesise findings into a brief; cross-check every load-bearing claim against
   the primary source.
4. Hand off: where the brief leans on a dependency whose real behaviour is
   unverified, run `environment-research` to probe it; then proceed to
   brainstorming.

## Output

A research brief in the doc taxonomy — `research` is exploration, not a decision.
Decisions become ADRs later; do not conflate them.

## Red flags — stop

- Unbounded research with no budget or scope (sprawl).
- A load-bearing claim taken from a secondary source without checking the primary.
- Treating the brief as settled fact instead of a hypothesis to validate.
