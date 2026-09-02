# agent-messages

Show agent messages exchanged within a run.

## Behavior

- The run detail page shows agent messages: from/to role, body, and a link to
  the card they belong to (when card-scoped).
- Messages for a card appear on that card; new messages show live via
  Hotwire/Turbo.
- Transcripts are read-only — there is no inline editing of agent messages.

## Acceptance notes

- Rails System Test: create a message on a card and assert it renders on the
  run detail / card; assert the from/to role and card link are present.
- Messages are tenant-scoped to the owning account.