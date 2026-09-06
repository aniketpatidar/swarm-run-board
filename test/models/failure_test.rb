# frozen_string_literal: true

require "test_helper"

class FailureTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")
  end

  test "valid failure scoped to a card" do
    card = @run.cards.create!(name: "Run board index", current_role: "coder", position: 1)
    failure = @run.failures.new(title: "Test suite failing", severity: "high", card: card)
    assert failure.valid?
  end

  test "valid failure without a card" do
    failure = @run.failures.new(title: "Canceled run", severity: "low")
    assert failure.valid?
  end

  test "title and severity are required" do
    failure = @run.failures.new
    assert_not failure.valid?
    assert_includes failure.errors[:title], "can't be blank"
    assert_includes failure.errors[:severity], "can't be blank"
  end

  test "severity must be one of high, medium, low" do
    failure = @run.failures.new(title: "Nope", severity: "critical")
    assert_not failure.valid?
    assert_includes failure.errors[:severity], "is not included in the list"
  end

  test "open failure is in the queue" do
    @run.failures.create!(title: "Still open", severity: "high")
    assert_equal 1, @run.failures.open.count
  end

  test "resolving marks the failure resolved and out of the queue" do
    failure = @run.failures.create!(title: "Canceled run", severity: "low")
    failure.resolve!

    assert_not_nil failure.reload.resolved_at
    assert_equal 0, @run.failures.open.count
  end

  test "reassigning leaves the failure open in the queue" do
    failure = @run.failures.create!(title: "Stuck card", severity: "medium")
    failure.reassign!

    assert_nil failure.reload.resolved_at
    assert_equal 1, @run.failures.open.count
  end
  test "resolve non-bang marks the failure resolved and out of the queue" do
    failure = @run.failures.create!(title: "Canceled run", severity: "low")
    assert failure.resolve
    assert_not_nil failure.reload.resolved_at
    assert_equal 0, @run.failures.open.count
    assert failure.resolve
  end

  test "reassign non-bang leaves the failure open in the queue" do
    failure = @run.failures.create!(title: "Stuck card", severity: "medium")
    assert failure.reassign
    assert_nil failure.reload.resolved_at
    assert_equal 1, @run.failures.open.count
  end
end
