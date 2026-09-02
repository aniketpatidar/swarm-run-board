# run-summary

Show a read-only summary for finished runs.

## Behavior

- Finished runs show a summary page: cards completed, cost total, failures
  resolved and failures still open.
- The summary is read-only and reachable from the board.

## Acceptance notes

- Rails System Test: set up a finished run with cards, costs, and failures;
  assert the summary shows the correct counts and totals, and that no edit
  affordances are present.
- Summary is tenant-scoped.