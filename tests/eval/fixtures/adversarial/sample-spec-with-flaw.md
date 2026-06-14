# RED fixture — sample spec with one planted design flaw

A tiny spec used to verify the adversarial-review skill: the design-flaw/race
lens MUST find the planted flaw; a cooperative self-review does not (see
`baseline-cooperative-miss.md`).

## Feature: reconnect event replay

On a client reconnect, the server replays missed events so the transcript is
complete.

- Each connection has a context `ctx` with `ctx.lastSeq` (the sequence number of
  the last event the client received).
- `ctx.lastSeq` is initialised to `0` when the context is created.
- On reconnect, the server calls `fetchEventsSince(ctx.lastSeq)` and streams the
  result to the client.

That is the whole design.

<!--
PLANTED FLAW (do not reveal in the spec body): ctx.lastSeq is initialised to 0
and is NEVER written back after a replay. So every reconnect replays from seq 0
and re-sends the entire transcript, duplicating it on the client. A unit test
with a mocked store that returns [] would pass while the real backend duplicates.
The design-flaw/race lens should catch this; testability/DoD should note the mock
would hide it.
-->
