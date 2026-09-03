# frozen_string_literal: true

class AuditEntry < ApplicationRecord
  belongs_to :run

  validates :action, :subject, presence: true
end
