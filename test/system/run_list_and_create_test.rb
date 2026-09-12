# frozen_string_literal: true

require "application_system_test_case"

class RunListAndCreateTest < ApplicationSystemTestCase
  test "the run board lists all runs with pack kind, status, and started time" do
    account = accounts(:one)
    sign_in_as(account.email_address, "password")

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
    account = accounts(:one)
    sign_in_as(account.email_address, "password")

    visit "/"
    within(".header__actions") { click_on "New run" }
    fill_in "Mission", with: "Triage weekend failures"
    select "six-pack", from: "Pack kind"
    click_on "Create run"

    within("#runs") do
      assert_text "Triage weekend failures"
      assert_text "six-pack"
      assert_text "running"
    end
  end

  test "creating a run removes the empty state prompt when the board is empty" do
    account = accounts(:one)
    sign_in_as(account.email_address, "password")
    account.runs.destroy_all

    visit "/"
    within("#runs") { assert_selector "#runs_empty" }

    within(".header__actions") { click_on "New run" }
    fill_in "Mission", with: "Triage weekend failures"
    select "six-pack", from: "Pack kind"
    click_on "Create run"

    within("#runs") do
      assert_text "Triage weekend failures"
      assert_no_selector "#runs_empty"
    end
  end

  test "the run board shows a status badge for each run" do
    account = accounts(:one)
    sign_in_as(account.email_address, "password")
    account.runs.create!(mission: "Ship alpha", pack_kind: "two-pack", status: "running")

    visit "/"

    within("#runs") { assert_selector ".badge", text: "running" }
  end

  test "the run board stays usable at mobile widths" do
    account = accounts(:one)
    sign_in_as(account.email_address, "password")
    account.runs.create!(mission: "Ship alpha", pack_kind: "two-pack", status: "running")

    visit "/"
    page.current_window.resize_to(375, 667)

    within("#runs") do
      assert_selector "th", text: "Started"
      assert_selector "tr", text: "Ship alpha"
    end
  end

  test "the run detail page stays usable at mobile widths" do
    account = accounts(:one)
    sign_in_as(account.email_address, "password")
    run = account.runs.create!(mission: "Ship alpha", pack_kind: "two-pack", status: "running")
    run.cards.create!(name: "Run board index", current_role: "coder", position: 1)

    visit run_path(run)
    page.current_window.resize_to(375, 667)

    assert_text "Ship alpha"
    within("#run_detail") do
      assert_text "Run board index"
    end
    assert_selector "#agent_messages"
  end

  test "the sign-in page stays usable at mobile widths" do
    visit "/"
    page.current_window.resize_to(375, 667)

    assert_text "Sign in"
    assert_field "Email address"
    assert_button "Sign in"
  end

  test "a signed-out visitor cannot see or create runs" do
    visit "/"

    assert_text "Sign in"
    assert_no_selector "#runs"
  end
end
