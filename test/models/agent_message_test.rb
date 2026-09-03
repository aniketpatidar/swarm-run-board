# frozen_string_literal: true

require "test_helper"

class AgentMessageTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")
  end

  test "valid message scoped to a card" do
    card = @run.cards.create!(name: "Run board index", current_role: "coder", position: 1)
    message = @run.agent_messages.new(from_role: "specifier", to_role: "coder", body: "Spec is ready.", card: card)
    assert message.valid?
  end

  test "valid message without a card" do
    message = @run.agent_messages.new(from_role: "coder", to_role: "cleaner", body: "Handing off.")
    assert message.valid?
  end

  test "from_role and to_role are required" do
    message = @run.agent_messages.new(body: "Spec is ready.")
    assert_not message.valid?
    assert_includes message.errors[:from_role], "can't be blank"
    assert_includes message.errors[:to_role], "can't be blank"
  end

  test "body is required" do
    message = @run.agent_messages.new(from_role: "specifier", to_role: "coder")
    assert_not message.valid?
    assert_includes message.errors[:body], "can't be blank"
  end
end
