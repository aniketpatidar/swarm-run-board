# frozen_string_literal: true

require "application_system_test_case"

class RunDetailWithCardsTest < ApplicationSystemTestCase
  test "a run detail page lists its cards in workflow order with role and state" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    run = account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack", status: "running", started_at: 1.day.ago)
    run.cards.create!(name: "Run board index", current_role: "done", position: 1)
    run.cards.create!(name: "Run detail page", current_role: "coder", position: 2)
    run.cards.create!(name: "Summary page", current_role: "blocked", position: 3)

    visit run_path(run)

    within("#cards") do
      assert_selector "li", text: "Run board index"
      assert_selector "li", text: "done"
      assert_selector "li", text: "Run detail page"
      assert_selector "li", text: "coder"
      assert_selector "li", text: "Summary page"
      assert_selector "li", text: "blocked"
    end

    first_card = all("#cards li").first
    last_card = all("#cards li").last
    assert_includes first_card.text, "Run board index"
    assert_includes last_card.text, "Summary page"
  end

  test "moving a card to the next lane updates the run detail state" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    run = account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack", status: "running", started_at: 1.day.ago)
    card = run.cards.create!(name: "Run board index", current_role: "specifier", position: 1)

    visit run_path(run)
    within("#card_#{card.id}") do
      click_on "Advance"
    end

    within("#card_#{card.id}") do
      assert_text "coder"
      assert_no_text "specifier"
    end
  end

  test "a run can only be viewed by its owning account" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    other = Account.create!(name: "Other", email_address: "other@example.com", password: "password123")
    sign_in_as("other@example.com", "password123")

    run = account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack", status: "running", started_at: 1.day.ago)

    visit run_path(run)

    assert_equal 404, page.status_code
    assert_no_text "Ship alpha"
  end
end
