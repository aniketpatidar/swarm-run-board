# frozen_string_literal: true

class Card < ApplicationRecord
  WORKFLOW_ROLES = %w[specifier coder cleaner architect hardender qa].freeze
  TERMINAL_STATES = %w[done blocked].freeze

  belongs_to :run
  has_many :agent_messages, dependent: :destroy

  scope :done, -> { where(current_role: "done") }

  validates :name, presence: true
  validates :current_role, presence: true, inclusion: { in: WORKFLOW_ROLES + TERMINAL_STATES }
  validates :position, presence: true

  def advance
    if (index = WORKFLOW_ROLES.index(current_role))
      update(current_role: WORKFLOW_ROLES[index + 1] || "done")
    else
      false
    end
  end

  def advance!
    if (index = WORKFLOW_ROLES.index(current_role))
      update!(current_role: WORKFLOW_ROLES[index + 1] || "done")
    end
  end

  def advanceable?
    WORKFLOW_ROLES.include?(current_role)
  end
end
