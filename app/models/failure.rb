# frozen_string_literal: true

class Failure < ApplicationRecord
  SEVERITIES = %w[high medium low].freeze

  belongs_to :run
  belongs_to :card, optional: true

  scope :open, -> { where(resolved_at: nil) }
  scope :resolved, -> { where.not(resolved_at: nil) }

  validates :title, presence: true
  validates :severity, presence: true, inclusion: { in: SEVERITIES }

  def resolve
    update(resolved_at: Time.current) &&
      run.audit_entries.create(action: "resolved", subject: title).persisted?
  end

  def resolve!
    update!(resolved_at: Time.current)
    run.audit_entries.create!(action: "resolved", subject: title)
  end

  def reassign
    run.audit_entries.create(action: "reassigned", subject: title).persisted?
  end

  def reassign!
    run.audit_entries.create!(action: "reassigned", subject: title)
  end
end
