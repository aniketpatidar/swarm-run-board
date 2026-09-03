# frozen_string_literal: true

class Failure < ApplicationRecord
  SEVERITIES = %w[high medium low].freeze

  belongs_to :run
  belongs_to :card, optional: true

  scope :open, -> { where(resolved_at: nil).order(:created_at, :id) }

  validates :title, presence: true
  validates :severity, presence: true, inclusion: { in: SEVERITIES }

  def resolve!(at: nil)
    return self if resolved_at?

    transaction do
      update!(resolved_at: at || Time.current)
      audit("resolved")
    end
    self
  end

  def reassign!
    audit("reassigned")
    self
  end

  private

  def audit(action)
    run.audit_entries.create!(action: action, subject: title)
  end
end
