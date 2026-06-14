# Environment Research — Harvest Formats

The experiment code is disposable; these two artifacts are what survive a probe.

## `decisions.jsonl` — one observation per line

Append-only NDJSON. One line per hypothesis tested. Schema:

```json
{
  "probe": "E01-plugin-sequencing",
  "hypothesis": "an orchestrator skill can run before superpowers' brainstorming",
  "mode": "execution|outcome|error|boundary",
  "predicted": "what you believed before running",
  "observed": "what actually happened when you ran it",
  "matched": true,
  "evidence": "path/to/transcript or one-line proof",
  "ts": "2026-06-12T00:00:00Z"
}
```

Rules: `ts` is passed in, never generated inside a workflow. `observed` is a fact
you watched, not an inference. If `matched` is false, the surprise is the most
valuable line in the file.

## `Lessons.md` — findings + graduation decision

```markdown
# <probe> — Lessons

## What we set out to learn
<the design question the probe must answer>

## What we observed
<prose summary of the decisions.jsonl lines — the real modes>

## Surprises (predicted != observed)
<the lines where matched=false; these are the point>

## Graduation decision
keep | iterate | discard — <one sentence why>

## Findings to embed in the brief/spec
- <fact 1, with the decisions.jsonl evidence>
- <fact 2 ...>
```

## Directory contract

```
docs/experiments/<probe>/
  README.md          # hypothesis, design, kill criterion (committed)
  decisions.jsonl    # observations (committed — the kept record)
  Lessons.md         # findings + graduation (committed)
  scratch/           # the disposable experiment code (GITIGNORED)
```
