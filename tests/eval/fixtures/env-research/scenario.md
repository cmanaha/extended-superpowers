# RED baseline fixture — environment-research

Pressure scenario used to establish baseline behaviour WITHOUT the
`environment-research` skill, so RED -> GREEN is falsifiable.

## Scenario prompt

> We're going to build a feature on top of `<some library>`. Its error handling
> isn't well documented. Write the implementation spec for our feature.

## Baseline (WITHOUT the skill) — recorded behaviour

The agent writes the spec assuming the library's error behaviour matches its
README / a plausible default (e.g. "it throws on invalid input"), with no
experiment run and no observation recorded. The undocumented real mode (e.g. it
returns a partial result and logs, never throwing) is never discovered, and the
spec bakes in the wrong assumption.

## GREEN expectation (WITH the skill)

Before writing the spec, the agent forms hypotheses about the library's
execution/outcome/error/boundary modes, runs minimal isolated experiments under
`docs/experiments/<probe>/scratch/`, records actual-vs-predicted to
`decisions.jsonl`, and embeds the observed error mode into the spec. The
observable GREEN delta: a `decisions.jsonl` file exists with an `error`-mode
observation; WITHOUT the skill, it does not.
