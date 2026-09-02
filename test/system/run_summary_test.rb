# frozen_string_literal: true

require "application_system_test_case"

class RunSummaryTest < ApplicationSystemTestCase
  test "a finished run shows a read-only summary with cards, cost, and failure counts" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    run = account.runs.create!(
      mission: "Ship alpha", pack_kind: "four-pack", status: "finished",
      started_at: 2.days.ago, ended_at: 1.day.ago
    )
    run.cards.create!(name: "Run board index", current_role: "done", position: 1)
    run.cards.create!(name: "Run detail page", current_role: "done", position: 2)
    run.cards.create!(name: "Summary page", current_role: "blocked", position: 3)
    run.cost_entries.create!(role: "coder", tokens_in: 600, tokens_out: 200, cost: 7.50)
    run.cost_entries.create!(role: "cleaner", tokens_in: 200, tokens_out: 50, cost: 2.00)
    run.failures.create!(title: "Fixed flake", severity: "low", resolved_at: 1.day.ago)
    run.failures.create!(title: "Still open", severity: "high")

    visit "/"
    within("#runs") do
      click_on "Ship alpha", match: :first
    end
    click_on "Summary"

    within("#run_summary") do
      assert_text "Completed"
      assert_text "2"
      assert_text "9.50"
      assert_text "Resolved failures"
      assert_text "1"
      assert_text "Open failures"
      assert_text "1"
    end
  end

  test "the summary page offers no editing affordances" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    run = account.runs.create!(
      mission: "Ship alpha", pack_kind: "four-pack", status: "finished",
      started_at: 2.days.ago, ended_at: 1.day.ago
    )

    visit run_summary_path(run)

    assert_no_button "Edit"
    assert_no_link "New run"
    assert_no_selector "form"
  end
end
