# frozen_string_literal: true

require "test_helper"

class CardTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")
  end

  test "valid card belongs to a run" do
    card = @run.cards.new(name: "Run board index", current_role: "specifier", position: 1)
    assert card.valid?
  end

  test "name is required" do
    card = @run.cards.new(current_role: "specifier", position: 1)
    assert_not card.valid?
    assert_includes card.errors[:name], "can't be blank"
  end

  test "current_role is required" do
    card = @run.cards.new(name: "Run board index", position: 1)
    assert_not card.valid?
    assert_includes card.errors[:current_role], "can't be blank"
  end

  test "current_role must be a known workflow role or terminal state" do
    card = @run.cards.new(name: "Run board index", current_role: "plumber", position: 1)
    assert_not card.valid?
    assert_includes card.errors[:current_role], "is not included in the list"
  end

  test "advance moves a card to the next workflow role" do
    card = @run.cards.create!(name: "Run board index", current_role: "specifier", position: 1)
    card.advance!
    assert_equal "coder", card.reload.current_role
  end

  test "advance past the final role marks the card done" do
    card = @run.cards.create!(name: "Run board index", current_role: "qa", position: 1)
    card.advance!
    assert_equal "done", card.reload.current_role
  end

  test "advance leaves an already done card done" do
    card = @run.cards.create!(name: "Run board index", current_role: "done", position: 1)
    card.advance!
    assert_equal "done", card.reload.current_role
  end

  test "cards ordered by position" do
    @run.cards.create!(name: "Third", current_role: "coder", position: 3)
    @run.cards.create!(name: "First", current_role: "specifier", position: 1)
    @run.cards.create!(name: "Second", current_role: "blocked", position: 2)

    assert_equal %w[First Second Third], @run.cards.map(&:name)
  end
end
