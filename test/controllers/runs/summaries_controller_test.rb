# frozen_string_literal: true

require "test_helper"

class Runs::SummariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    sign_in_as(@account)
  end

  test "summary shows completed cards, cost total, and failure counts" do
    run = @account.runs.create!(
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

    get run_summary_path(run)
    assert_response :success
    assert_select "#run_summary" do
      assert_select "dt", text: "Status"
      assert_select "dd", text: "Completed"
      assert_select "dd", text: "2"
      assert_select "dd", text: "9.50"
      assert_select "dd", text: "1"
    end
    assert_select "dt", text: "Resolved failures"
    assert_select "dt", text: "Open failures"
  end

  test "summary is tenant-scoped" do
    run = accounts(:two).runs.create!(mission: "Other", pack_kind: "two-pack")
    get run_summary_path(run)
    assert_response :not_found
  end
end
