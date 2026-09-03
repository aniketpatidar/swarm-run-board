# frozen_string_literal: true

class AgentMessage < ApplicationRecord
  belongs_to :run
  belongs_to :card, optional: true

  validates :from_role, :to_role, :body, presence: true
end
