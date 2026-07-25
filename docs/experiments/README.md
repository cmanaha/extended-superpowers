# Experiments — the disposable-tree contract

This directory holds **environment-research** probes: empirical experiments that
characterise how a dependency actually behaves before a spec relies on it.

The rule that makes this safe and pristine:

- **Code is disposable, knowledge is kept.** Each probe's experiment code lives in
  `<probe>/scratch/` and is **gitignored** — it never enters production, and the
  whole tree is a single delete target.
- **What survives, committed:** `<probe>/README.md` (hypothesis + design + kill
  criterion), `<probe>/decisions.jsonl` (observations), `<probe>/Lessons.md`
  (findings + keep/iterate/discard).
- **Zero coupling:** production code never imports from an experiment.

See the `environment-research` skill and its `reference.md` for the formats.

## Probes

- `E01-plugin-sequencing/` — does superpowers' brainstorming preempt a phase that
  is meant to run before it? The architecture gate for this plugin.
- `E02-plugin-workflows/` — can this plugin *ship* a workflow? The distribution
  gate for converting any prose-enforced phase into a script (ADR-0006).
