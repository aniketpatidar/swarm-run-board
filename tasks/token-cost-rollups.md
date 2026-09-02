# token-cost-rollups

Track and roll up token/cost usage per run and per role.

## Behavior

- Cost entries can be added for a run, with an optional role scope (tokens in,
  tokens out, cost).
- The run detail page rolls these up: a total per role and a run grand total.
- Costs render deterministically and are stable across reloads (no
  time-dependent or random output).

## Acceptance notes

- Rails System Test: add cost entries across two roles, reload, and assert the
  per-role totals and grand total are correct and unchanged.
- Entries are tenant-scoped.