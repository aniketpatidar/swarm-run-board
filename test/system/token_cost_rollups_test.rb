# frozen_string_literal: true

require "application_system_test_case"

class TokenCostRollupsTest < ApplicationSystemTestCase
  test "adding cost entries rolls them up per role and into a grand total on the run detail" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    run = account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack", status: "running", started_at: 1.day.ago)

    visit run_path(run)
    fill_in "Role", with: "specifier"
    fill_in "Tokens in", with: "400"
    fill_in "Tokens out", with: "100"
    fill_in "Cost", with: "5.00"
    click_on "Add cost"

    fill_in "Role", with: "coder"
    fill_in "Tokens in", with: "600"
    fill_in "Tokens out", with: "200"
    fill_in "Cost", with: "7.50"
    click_on "Add cost"

    within("#cost_rollup") do
      assert_text "specifier"
      assert_text "5.00"
      assert_text "coder"
      assert_text "7.50"
      assert_text "12.50"
    end
  end

  test "cost rollups are stable across reloads" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    run = account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack", status: "running", started_at: 1.day.ago)
    run.cost_entries.create!(role: "specifier", tokens_in: 400, tokens_out: 100, cost: 5.00)
    run.cost_entries.create!(role: "coder", tokens_in: 600, tokens_out: 200, cost: 7.50)

    visit run_path(run)
    grand_total = find("#cost_rollup .grand-total").text

    visit run_path(run)
    assert_equal grand_total, find("#cost_rollup .grand-total").text
  end
end
