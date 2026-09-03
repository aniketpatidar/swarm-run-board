# frozen_string_literal: true

require_relative "property_test_helper"

class FailureTriagePropertyTest < ActiveSupport::TestCase
  SEVERITIES = Failure::SEVERITIES

  include PropertyTestSupport

  def run_with_failures
    property_of {
      account = Account.create!(name: "P #{range(1, 100_000)}", email_address: "p#{range(1, 100_000_000)}@example.com", password: "password123")
      run = account.runs.create!(mission: "Prop #{range(1, 100_000)}", pack_kind: "four-pack")
      n = range(0, 12)
      failures = Array.new(n) do
        run.failures.create!(title: "Failure #{range(1, 100_000)}", severity: choose(*SEVERITIES))
      end
      [ run, failures ]
    }
  end

  test "a failure is in the open queue exactly while it is unresolved" do
    run_with_failures.check(30) { |(run, failures)|
      resolved = failures.sample(failures.empty? ? 0 : failures.size / 3).to_a
      resolved.each(&:resolve!)
      run.failures.reload

      open_ids = run.failures.open.pluck(:id)
      failures.each do |failure|
        if resolved.include?(failure)
          refute_includes open_ids, failure.id, "resolved failure #{failure.id} must not be open"
        else
          assert_includes open_ids, failure.id, "unresolved failure #{failure.id} must be open"
        end
      end
    }
  end

  test "resolving is idempotent and records exactly one audit entry per failure" do
    run_with_failures.check(30) { |(run, failures)|
      failures.each do |failure|
        calls = 1 + failures.size % 5
        calls.times { failure.resolve! }
      end

      failures.each do |failure|
        audit_actions = run.audit_entries.where(subject: failure.title).pluck(:action)
        assert_equal 1, audit_actions.count("resolved"),
          "failure #{failure.id} must produce exactly one resolved audit entry"
      end
    }
  end

  test "the open queue orders deterministically by created_at then id" do
    run_with_failures.check(30) { |(run, failures)|
      open = run.failures.open.to_a
      assert_equal open.sort_by { |f| [ f.created_at, f.id ] }, open,
        "open queue must be ordered by created_at then id"
    }
  end
end
