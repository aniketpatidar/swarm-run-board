# Swarm Run Board

An operations surface for agent swarms: a place to review runs, cards, agent messages, token/cost rollups, and failures that need human triage. The swarm itself is the subject — **SwarmForge dogfooding its own runs**.

## Features

- **Live Observation**: Watch the swarm run live. Agent messages stream in through Turbo.
- **Run & Card Tracking**: View runs and individual units of work (cards) as they move through role handoffs (e.g. `specifier` -> `coder` -> `architect` -> `Done`).
- **Cost Analytics**: Keep track of token and cost rollups per run, per role, or per model.
- **Failure Triage**: Easily triage incidents like test failures, stuck cards, or aborted runs in a centralized queue.
- **Automated Summaries**: Get complete overviews for finished runs, detailing completed cards, total costs, and resolved failures.

## Installation

```bash
bundle install
rails db:setup
```

## Usage

Start the local server with Solid Queue running in the background:

```bash
./bin/dev
```

Once the server is running, navigate to `http://localhost:3000` to access the operations board and review swarm sessions.

## Testing

The project uses Minitest and Rails System Tests (with Capybara/Cuprite) for end-to-end acceptance testing without Gherkin.

To run the test suite:

```bash
rails test
rails test:system
```

## Contributing

Please read `CONTRIBUTING.md` for details on our code of conduct, and the process for submitting pull requests to us.

## License

This project is licensed under the MIT License - see the `LICENSE.md` file for details.
