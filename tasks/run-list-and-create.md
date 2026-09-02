# run-list-and-create

Build the run board index: a list of all swarm runs.

## Behavior

- The board shows all runs with their pack kind (two-pack / four-pack /
  six-pack), status (running / finished / failed / aborted), and started time.
- The operator can create a run from the board: enter a mission and pick the
  pack kind, then submit.
- A newly created run appears in the list immediately (Hotwire/Turbo refresh),
  in running state.

## Acceptance notes

- Acceptance is a Rails System Test (Capybara/Cuprite) driving the UI: visit
  the board, click create, fill the form, submit, and assert the new run shows.
- Runs belong to an account; a signed-out visitor must not see or create them.