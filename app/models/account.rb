# frozen_string_literal: true

class Account < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :runs, dependent: :destroy

  normalizes :email_address, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true
end
