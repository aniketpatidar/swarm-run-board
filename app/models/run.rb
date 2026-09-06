# frozen_string_literal: true

class Run < ApplicationRecord
  belongs_to :account
  has_many :cards, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :run
  has_many :agent_messages, dependent: :destroy
  has_many :cost_entries, dependent: :destroy
  has_many :failures, dependent: :destroy
  has_many :audit_entries, dependent: :destroy

  attribute :started_at, :datetime, default: -> { Time.current }

  PACK_KINDS = %w[two-pack four-pack six-pack].freeze
  STATUSES = %w[running finished failed aborted].freeze

  scope :newest_first, -> { order(created_at: :desc) }

  def cost_rollup
    CostRollup.from_entries(cost_entries.select(&:persisted?))
  end

  def completed_cards_count
    cards.done.count
  end

  def total_cost
    cost_entries.sum(:cost)
  end

  def resolved_failures_count
    failures.resolved.count
  end

  def open_failures_count
    failures.open.count
  end

  validates :mission, presence: true
  validates :pack_kind, inclusion: { in: PACK_KINDS }
  validates :status, inclusion: { in: STATUSES }
end
