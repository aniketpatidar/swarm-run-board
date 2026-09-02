# frozen_string_literal: true

class Run < ApplicationRecord
  belongs_to :account

  attribute :started_at, :datetime, default: -> { Time.current }

  PACK_KINDS = %w[two-pack four-pack six-pack].freeze
  STATUSES = %w[running finished failed aborted].freeze

  scope :newest_first, -> { order(created_at: :desc) }

  validates :mission, presence: true
  validates :pack_kind, inclusion: { in: PACK_KINDS }
  validates :status, inclusion: { in: STATUSES }
end
