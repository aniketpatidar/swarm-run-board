# frozen_string_literal: true

require_relative "property_test_helper"

class AgentMessagePropertyTest < ActiveSupport::TestCase
  ROLES = %w[operator specifier coder cleaner architect hardender qa].freeze

  setup do
    @account = Account.create!(name: "Message Prop Account", email_address: "msg-prop-#{rand(1_000_000)}@example.com", password: "password")
    @run = @account.runs.create!(mission: "Property run", pack_kind: "four-pack")
  end

  test "a run-level message round-trips its attributes unchanged" do
    property_of {
      from = choose(*ROLES)
      to = choose(*ROLES)
      body = array(range(1, 160)) { choose(*(("a".."z").to_a + [ " ", "\n", "-", "!" ])) }.join
      [ from, to, body ]
    }.check(50) { |(from, to, body)|
      message = @run.agent_messages.create!(from_role: from, to_role: to, body: body)
      reloaded = AgentMessage.find(message.id)

      assert_equal from, reloaded.from_role
      assert_equal to, reloaded.to_role
      assert_equal body, reloaded.body
      assert_nil reloaded.card_id
      assert_equal @run.id, reloaded.run_id
    }
  end

  test "a card-scoped message round-trips its attributes including the card link" do
    property_of {
      from = choose(*ROLES)
      to = choose(*ROLES)
      body = array(range(1, 160)) { choose(*(("a".."z").to_a + [ " ", "\n", "-", "!" ])) }.join
      [ from, to, body ]
    }.check(50) { |(from, to, body)|
      card = @run.cards.create!(name: "c", current_role: "specifier", position: 1)
      message = @run.agent_messages.create!(from_role: from, to_role: to, body: body, card: card)
      reloaded = AgentMessage.find(message.id)

      assert_equal from, reloaded.from_role
      assert_equal to, reloaded.to_role
      assert_equal body, reloaded.body
      assert_equal card.id, reloaded.card_id
      assert_equal @run.id, reloaded.run_id
    }
  end

  test "a message missing body, from role, or to role is invalid" do
    property_of {
      field = choose(:body, :from_role, :to_role)
      [ field, choose(*ROLES), array(range(1, 60)) { choose(*(("a".."z").to_a + [ " " ])) }.join ]
    }.check(50) { |(missing, role, text)|
      attrs = { from_role: role, to_role: role, body: text }
      attrs[missing] = ""

      message = @run.agent_messages.new(attrs)
      assert_not message.valid?, "expected invalid when #{missing} is blank"
      assert_includes message.errors[missing], "can't be blank"
    }
  end
end
