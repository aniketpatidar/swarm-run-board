# frozen_string_literal: true

require_relative "property_test_helper"

class CardPropertyTest < ActiveSupport::TestCase
  setup do
    @account = Account.create!(name: "Card Prop Account", email_address: "card-prop-#{rand(1_000_000)}@example.com", password: "password")
    @run = @account.runs.create!(mission: "Property run", pack_kind: "four-pack")
  end

  test "a card built with any name, position, and a known role is valid" do
    property_of {
      name = array(range(1, 80)) { choose(*(("a".."z").to_a + [ " ", "-" ])) }.join
      [ name, choose(*Card::WORKFLOW_ROLES + Card::TERMINAL_STATES), range(1, 50) ]
    }.check(50) { |(name, role, position)|
      card = @run.cards.new(name: name, current_role: role, position: position)
      assert card.valid?, "expected valid card for role=#{role.inspect}: #{card.errors.full_messages}"
      assert_includes Card::WORKFLOW_ROLES + Card::TERMINAL_STATES, card.current_role
    }
  end

  test "a card rejects any current_role outside the allowed set" do
    property_of {
      string
    }.check(50) { |garbage|
      card = @run.cards.new(name: "Any", current_role: garbage, position: 1)
      if (Card::WORKFLOW_ROLES + Card::TERMINAL_STATES).include?(garbage)
        assert card.valid?
      else
        assert_not card.valid?, "expected invalid current_role=#{garbage.inspect}"
        assert_includes card.errors[:current_role], "is not included in the list"
      end
    }
  end

  test "advance moves every workflow role to the next role, and the last role to done" do
    property_of {
      role = choose(*Card::WORKFLOW_ROLES)
      [ role, Card::WORKFLOW_ROLES.index(role) ]
    }.check(50) { |(role, index)|
      card = @run.cards.create!(name: "Advance", current_role: role, position: 1)
      card.advance!

      expected = Card::WORKFLOW_ROLES[index + 1] || "done"
      assert_equal expected, card.reload.current_role
    }
  end

  test "advance is a no-op for terminal states" do
    property_of {
      state = choose(*Card::TERMINAL_STATES)
      state
    }.check(25) { |state|
      card = @run.cards.create!(name: "Terminal", current_role: state, position: 1)
      card.advance!
      assert_equal state, card.reload.current_role
    }
  end

  test "a persisted card round-trips its attributes unchanged" do
    property_of {
      name = array(range(1, 80)) { choose(*(("a".."z").to_a + [ " " ])) }.join
      [ name, choose(*Card::WORKFLOW_ROLES + Card::TERMINAL_STATES), range(1, 50) ]
    }.check(50) { |(name, role, position)|
      card = @run.cards.create!(name: name, current_role: role, position: position)
      reloaded = Card.find(card.id)

      assert_equal name, reloaded.name
      assert_equal role, reloaded.current_role
      assert_equal position, reloaded.position
      assert_equal @run.id, reloaded.run_id

      card.destroy!
    }
  end

  test "cards order by position then id" do
    property_of {
      positions = array(range(1, 6)) { range(1, 100) }
      positions
    }.check(25) { |positions|
      run = Run.create!(account: @account, mission: "Order run", pack_kind: "two-pack")

      cards = positions.each_with_index.map do |pos, i|
        run.cards.create!(name: "card #{i}", current_role: "specifier", position: pos)
      end

      expected = cards.sort_by { |c| [ c.position, c.id ] }.map(&:id)
      assert_equal expected, run.cards.map(&:id)
    }
  end
end
