# run-detail-with-cards

Show a single run with its cards and their lifecycle.

## Behavior

- A run's detail page lists its cards in workflow order, each showing the
  current role and its state (in a role lane / done / blocked).
- Cards move through role handoffs (e.g. specifier -> coder -> cleaner ->
  architect -> hardender -> QA -> done) and the detail page reflects each
  transition.
- The board card state is the source of truth for the current lane.

## Acceptance notes

- Rails System Test (Capybara/Cuprite): open a run with cards, move a card to
  the next lane via the UI, and assert the run detail reflects the new state.
- Only the run's owning account can view the run; cross-account access is
  forbidden (negative-space test).