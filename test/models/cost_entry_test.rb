# frozen_string_literal: true

require "test_helper"

class CostEntryTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")
  end

  test "valid entry scoped to a role" do
    entry = @run.cost_entries.new(role: "specifier", tokens_in: 400, tokens_out: 100, cost: 5.00)
    assert entry.valid?
  end

  test "role is optional for run-level entries" do
    entry = @run.cost_entries.new(tokens_in: 400, tokens_out: 100, cost: 5.00)
    assert entry.valid?
  end

  test "cost is required" do
    entry = @run.cost_entries.new(role: "specifier", tokens_in: 400, tokens_out: 100)
    assert_not entry.valid?
    assert_includes entry.errors[:cost], "can't be blank"
  end

  test "cost is a decimal with two places" do
    entry = @run.cost_entries.create!(role: "coder", tokens_in: 600, tokens_out: 200, cost: "7.50")
    assert_equal 7.5, entry.cost.to_f
  end
end
