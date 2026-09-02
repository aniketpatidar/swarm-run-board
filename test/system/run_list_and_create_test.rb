# frozen_string_literal: true

require "application_system_test_case"

class RunListAndCreateTest < ApplicationSystemTestCase
  test "the run board lists all runs with pack kind, status, and started time" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    account.runs.create!(mission: "Ship alpha", pack_kind: "two-pack", status: "running", started_at: 1.day.ago)
    account.runs.create!(mission: "Dogfood board", pack_kind: "six-pack", status: "failed", started_at: 2.days.ago)

    visit "/"

    within("#runs") do
      assert_selector "th", text: "Started"
      assert_selector "tr", text: "Ship alpha"
      assert_selector "tr", text: "two-pack"
      assert_selector "tr", text: "running"
      first_run = account.runs.find_by(mission: "Ship alpha")
      within first("tr", text: "Ship alpha") do
        assert_selector "time[datetime='#{first_run.started_at.iso8601}']"
      end

      assert_selector "tr", text: "Dogfood board"
      assert_selector "tr", text: "six-pack"
      assert_selector "tr", text: "failed"
    end
  end

  test "creating a run adds it to the list immediately in a running state" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    visit "/"
    click_on "New run"
    fill_in "Mission", with: "Triage weekend failures"
    select "six-pack", from: "Pack kind"
    click_on "Create run"

    within("#runs") do
      assert_text "Triage weekend failures"
      assert_text "six-pack"
      assert_text "running"
    end
  end

  test "a signed-out visitor cannot see or create runs" do
    Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")

    visit "/"

    assert_text "Sign in"
    assert_no_selector "#runs"
  end
end
