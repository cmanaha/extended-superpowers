# RED baseline — cooperative self-review (WITHOUT adversarial-review)

Recorded behaviour: the author-agent reviews its OWN spec cooperatively and
approves it, missing the planted flaw.

## Baseline output (cooperative)

> The reconnect replay design looks good. It tracks the last received sequence in
> `ctx.lastSeq` and replays from there with `fetchEventsSince`. Clean and minimal.
> Ready to plan.

The cooperative reviewer confirms the happy-path story and never asks "where is
`ctx.lastSeq` written back?" — so the duplicate-on-every-reconnect bug ships.

## GREEN expectation (WITH adversarial-review)

The design-flaw/race lens, instructed to refute, traces the lifecycle of
`ctx.lastSeq`, finds it is initialised to 0 and never updated, and reports:

> [BLOCKER] spec:reconnect replay — ctx.lastSeq is initialised to 0 and never
> written back after replay, so every reconnect replays from seq 0 and duplicates
> the transcript → persist the last replayed seq back to ctx.lastSeq.

Observable GREEN delta: the lens returns a BLOCKER naming the unwritten cursor;
the cooperative baseline returns "ready".
