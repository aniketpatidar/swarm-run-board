# frozen_string_literal: true

require "test_helper"

class AuditEntryTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")
  end

  test "valid audit entry belongs to a run" do
    entry = @run.audit_entries.new(action: "resolved", subject: "Canceled run")
    assert entry.valid?
  end

  test "action and subject are required" do
    entry = @run.audit_entries.new
    assert_not entry.valid?
    assert_includes entry.errors[:action], "can't be blank"
    assert_includes entry.errors[:subject], "can't be blank"
  end
end
