# failure-triage

Provide a triage queue for swarm failures.

## Behavior

- Failures (failed verification, stuck card, aborted run) appear in a triage
  queue with a severity and the affected run/card.
- The operator can resolve a failure or reassign it; resolving moves it out of
  the queue. Both actions leave a retained audit trail on the run.

## Acceptance notes

- Rails System Test: create a failure, assert it shows in the triage queue with
  severity and target, then resolve it from the UI and assert it leaves the
  queue while the audit trail remains.
- Failures are tenant-scoped.