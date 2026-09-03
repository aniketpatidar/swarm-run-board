# frozen_string_literal: true

class CostEntry < ApplicationRecord
  belongs_to :run

  validates :tokens_in, :tokens_out, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
