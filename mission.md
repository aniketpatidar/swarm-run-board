# Swarm Run Board

An operations surface for agent swarms: a place to review runs, cards, agent
messages, token/cost rollups, and failures that need human triage. The swarm
itself is the subject — SwarmForge dogfooding its own runs.

## Stack

| Layer | Choice |
|---|---|
| Framework | Rails 8 (Hotwire — Turbo + Stimulus) |
| Auth | Rails 8 generated authentication (no Devise) |
| Database | SQLite 3 |
| Frontend | Importmap (no Node/webpack), standard ERB |
| Background jobs | Solid Queue (database-backed) |
| Tests | Minitest + fixtures; Rails System Tests (Capybara/Cuprite) for acceptance |
| Quality | rubocop, brakeman, rubycritic, reek, mutant |

## Domain

- **Run** — one swarm session (a worktree + tmux window set). Has a mission,
  a pack kind (two-pack / four-pack / six-pack), started/ended times, and a
  status (running, finished, failed, aborted).
- **Card** — a unit of work within a run, moving through role handoffs
  (e.g. specifier -> coder -> refactorer -> architect -> Done). Tracks the
  current role, handoff history, and block state.
- **AgentMessage** — messages exchanged between roles (git_handoff drafts,
  commits, notes). Belongs to a run and a card (when card-scoped), with
  direction (from/to role) and a body.
- **CostEntry** — token/cost rollup per run, per role, or per model. Aggregated
  into a run-level rollup shown on the run detail page.
- **Failure** — a triage-able incident: failed verification, test failure,
  stuck card, or aborted run. Human marks it resolved / reassigns.

## Key Flows

1. Operator starts a run; run + cards are created and shown on the board.
2. Agent messages stream in; operator watches the swarm run live (Turbo).
3. Token/cost entries accumulate and roll up per run and per role.
4. Failures appear in a triage queue; humans resolve or reassign them.
5. Done runs get a summary: cards completed, cost total, failures resolved.

## Acceptance Style

Specifier writes Rails System Tests (Capybara/Cuprite). No Gherkin. Tests
exercise the UI (clicks, fills, Turbo waits) end to end.