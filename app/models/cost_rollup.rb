# frozen_string_literal: true

class CostRollup
  def self.from_entries(entries)
    totals_by_role = entries.each_with_object(Hash.new(0.0)) do |entry, acc|
      acc[entry.role] += entry.cost.to_d
    end
    grand_total = totals_by_role.values.sum.to_d
    new(per_role: totals_by_role, grand_total: grand_total)
  end

  attr_reader :per_role, :grand_total

  def initialize(per_role:, grand_total:)
    @per_role = per_role.freeze
    @grand_total = grand_total.to_d
  end
end
