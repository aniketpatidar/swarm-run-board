# frozen_string_literal: true

require_relative "property_test_helper"

class CostRollupPropertyTest < ActiveSupport::TestCase
  ROLES = [ nil, "specifier", "coder", "cleaner", "architect", "hardender", "qa" ].freeze

  include PropertyTestSupport

  def random_entries
    property_of {
      n = range(0, 30)
      Array.new(n) do
        cost = range(0, 100_000) / 100.0
        CostEntry.new(role: choose(*ROLES), tokens_in: range(0, 100_000),
                      tokens_out: range(0, 100_000), cost: cost)
      end
    }
  end

  test "the grand total conserves the sum of every entry's cost" do
    random_entries.check(100) { |entries|
      rollup = CostRollup.from_entries(entries)
      expected = entries.sum { |e| e.cost.to_d }
      assert_in_delta expected, rollup.grand_total, 0.0001,
        "grand_total #{rollup.grand_total} must equal sum of entry costs #{expected}"
    }
  end

  test "the grand total equals the sum of the per-role totals" do
    random_entries.check(100) { |entries|
      rollup = CostRollup.from_entries(entries)
      assert_in_delta rollup.per_role.values.sum, rollup.grand_total, 0.0001,
        "sum of per-role totals #{rollup.per_role.values.sum} must equal grand_total #{rollup.grand_total}"
    }
  end

  test "each role total sums exactly that role's entry costs" do
    random_entries.check(100) { |entries|
      rollup = CostRollup.from_entries(entries)
      entries.group_by(&:role).each do |role, role_entries|
        expected = role_entries.sum { |e| e.cost.to_d }
        assert_in_delta expected, rollup.per_role.fetch(role), 0.0001,
          "role #{role.inspect} total #{rollup.per_role.fetch(role)} must equal #{expected}"
      end
    }
  end

  test "the rollup is a stable pure function of its entries" do
    random_entries.check(100) { |entries|
      first = CostRollup.from_entries(entries)
      second = CostRollup.from_entries(entries)
      assert_equal first.per_role, second.per_role
      assert_equal first.grand_total, second.grand_total
    }
  end

  test "an empty entry set yields no per-role totals and a zero grand total" do
    rollup = CostRollup.from_entries([])
    assert_empty rollup.per_role
    assert_equal 0, rollup.grand_total
  end
end
