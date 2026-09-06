# frozen_string_literal: true

require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "normalizes email address" do
    account = Account.new(name: "Ops", email_address: "  Ops@Example.com ", password: "password123")
    account.valid?
    assert_equal "ops@example.com", account.email_address
  end

  test "email address must be unique" do
    Account.create!(name: "Ops", email_address: "dup@example.com", password: "password123")
    duplicate = Account.new(name: "Ops2", email_address: "dup@example.com", password: "password123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email_address], "has already been taken"
  end

  test "has many runs destroyed on account destroy" do
    account = Account.create!(name: "Ops", email_address: "runs@example.com", password: "password123")
    account.runs.create!(mission: "Ship", pack_kind: "two-pack")
    assert_difference "Run.count", -1 do
      account.destroy
    end
  end
end
