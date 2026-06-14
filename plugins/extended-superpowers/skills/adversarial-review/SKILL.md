---
name: adversarial-review
description: Use when you have a spec, plan, or implementation that must be independently reviewed before it is trusted, committed, or advanced to the next phase — especially at the spec→plan, plan→code, and code→merge gates; triggers on "review this adversarially", "find what's wrong with this spec/plan", "attack this design", or any checkpoint where an artifact should be refuted by fresh eyes rather than graded cooperatively.
---

# Adversarial Review

Cooperative review confirms; adversarial review refutes. An author cannot grade
their own work — they produce what looks compliant because they wrote it to look
compliant. Dispatch fresh reviewers whose job is to find flaws, each through one
named lens, separate from the author's context.

## Core principle

Run the full named-lens set for the artifact, in parallel, each as an independent
reviewer instructed to **enumerate, don't fix**, and to **default to finding
problems**. Loop until BLOCKER/MAJOR findings are resolved.

## The lens contract (binding — dispatch the FULL set for the artifact)

| Artifact | Named lenses (one fresh reviewer each) |
|----------|----------------------------------------|
| spec | factual-grounding, completeness, design-flaw/race, testability/DoD |
| plan | spec-coverage+guardrails, testing+trackability, sequencing+anti-hubris |
| implementation | spec-compliance, then code-quality |

- A single generic reviewer is NOT adversarial review. Dispatch every lens in the
  artifact's row.
- For implementation, run spec-compliance FIRST, then code-quality — they catch
  different bug classes (compliance: "did you build what was specified";
  quality: "did you build it correctly").
- sequencing+anti-hubris enforces "don't boil the ocean — justify every number"
  — every bare constant must carry its selection logic (a `threshold-reasoning`
  skill, if installed, helps).

## Protocol

1. **Look up the governing principle.** If a memory store is available (e.g. a
   `memory` MCP server or a project principles doc), the main session looks up the
   applicable Clean-Architecture / Pragmatic-Programmer principle and includes it
   in each reviewer's brief; otherwise it states the principle inline from the
   artifact's own context. (Reviewers read files; the principle is passed in.)
2. **Dispatch the full lens set in parallel.** For spec and plan lenses, one
   `adversarial-reviewer` agent per lens. For the implementation lenses, the
   bundled `spec-compliance-reviewer` then `code-quality-reviewer`. All run
   separate from the author. If richer specialists are installed — e.g. a
   `pr-review-toolkit` plugin, or any structural-review agent — dispatch them as
   optional add-ons.
3. **Collect severity-graded findings.** Each reviewer returns lines of
   `[BLOCKER|MAJOR|MINOR] <file>:<where> — <problem> → <fix>` and a one-line
   verdict. No reviewer modifies a file.
4. **Loop until clean.** The author fixes; re-dispatch the lenses that found
   issues; repeat. Never accept "close enough" on a BLOCKER or MAJOR.

## Separate model from author

The reviewer must not be the context that wrote the artifact. Fresh eyes, ideally
a different model than the builder, with no sunk cost in the work.

## Output

The artifact plus a findings ledger. The gate opens only when every BLOCKER and
MAJOR is resolved; MINORs are recorded and dispositioned.

## Red flags — stop

- The author grades its own work, or a single reviewer stands in for the set.
- A reviewer fixes things instead of enumerating.
- "Looks good" with no attempt to refute.
- Skipping the re-review loop after a fix.
- Code-quality review started before spec-compliance is clean.
- A bare number survives the sequencing+anti-hubris lens unjustified.
