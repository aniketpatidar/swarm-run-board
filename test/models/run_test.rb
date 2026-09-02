# frozen_string_literal: true

require "test_helper"

class RunTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
  end

  test "valid run belongs to an account" do
    run = @account.runs.new(mission: "Ship alpha", pack_kind: "two-pack")
    assert run.valid?
  end

  test "mission is required" do
    run = @account.runs.new(pack_kind: "two-pack")
    assert_not run.valid?
    assert_includes run.errors[:mission], "can't be blank"
  end

  test "pack_kind must be one of the allowed values" do
    run = @account.runs.new(mission: "Ship", pack_kind: "nine-pack")
    assert_not run.valid?
    assert_includes run.errors[:pack_kind], "is not included in the list"
  end

  test "status must be one of the allowed values" do
    run = @account.runs.new(mission: "Ship", status: "paused")
    assert_not run.valid?
    assert_includes run.errors[:status], "is not included in the list"
  end

  test "persisted run defaults to running with a two-pack" do
    run = @account.runs.create!(mission: "Ship beta")
    assert_equal "running", run.status
    assert_equal "two-pack", run.pack_kind
  end
end
