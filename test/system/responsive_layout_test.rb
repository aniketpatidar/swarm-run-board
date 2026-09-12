# frozen_string_literal: true

require "application_system_test_case"

class ResponsiveLayoutTest < ApplicationSystemTestCase
  test "long missions wrap in the run board table instead of widening it" do
    account = accounts(:one)
    sign_in_as(account.email_address, "password")

    account.runs.create!(
      mission: "ThisMissionNameIsASingleWordThatGoesOnForQuiteSomeTimeAndShouldWrapInsteadOfForcingTheTableToOverflowTheViewportBoundaries",
      pack_kind: "two-pack", status: "running"
    )

    page.current_window.resize_to(640, 900)
    visit "/"

    metrics = page.evaluate_script(<<~JS)
      (function () {
        var table = document.getElementById('runs');
        var scroller = table.closest('.scroller');
        return { scroll: scroller.scrollWidth, client: scroller.clientWidth };
      })()
    JS

    assert metrics["scroll"] <= metrics["client"] + 1,
      "expected the runs table to fit its scroller, was #{metrics["scroll"]} > #{metrics["client"]}"
  end

  test "the run board does not overflow the page at phone widths" do
    account = accounts(:one)
    sign_in_as(account.email_address, "password")
    account.runs.create!(mission: "Ship alpha", pack_kind: "six-pack", status: "running")

    page.current_window.resize_to(320, 667)
    visit "/"

    within("#runs") do
      assert_selector "tr", text: "Ship alpha"
      assert_selector ".badge", text: "running"
    end
    assert_no_page_overflow
  end

  test "the new run form is usable and creates a run at phone widths" do
    account = accounts(:one)
    sign_in_as(account.email_address, "password")

    page.current_window.resize_to(320, 667)
    visit new_run_path

    fill_in "Mission", with: "Triage weekend failures"
    select "six-pack", from: "Pack kind"
    click_on "Create run"

    within("#runs") { assert_text "Triage weekend failures" }
    assert_no_page_overflow
  end

  test "the run detail page shows cards, cost rollup, and triage at phone widths" do
    account = accounts(:one)
    sign_in_as(account.email_address, "password")
    run = account.runs.create!(mission: "Ship alpha", pack_kind: "two-pack", status: "running")
    run.cards.create!(name: "Run board index", current_role: "coder", position: 1)
    run.agent_messages.create!(from_role: "specifier", to_role: "coder", body: "Spec is ready for review.")
    run.cost_entries.create!(role: "coder", tokens_in: 100, tokens_out: 50, cost: 1.5)
    run.failures.create!(title: "Verification failed on card X", severity: "high")

    page.current_window.resize_to(320, 667)
    visit run_path(run)

    assert_text "Run board index"
    within("#cost_rollup") { assert_text "1.50" }
    within("#triage_queue") { assert_selector "#failure_#{run.failures.first.id}" }
    assert_no_page_overflow
  end

  test "a long mission does not force the detail or summary header outside the viewport at phone widths" do
    account = accounts(:one)
    sign_in_as(account.email_address, "password")
    run = account.runs.create!(
      mission: "ThisMissionNameIsASingleWordThatGoesOnForQuiteSomeTimeAndShouldWrapInsteadOfForcingTheTableToOverflowTheViewportBoundaries",
      pack_kind: "two-pack", status: "running"
    )

    page.current_window.resize_to(320, 667)
    visit run_path(run)
    assert_no_page_overflow

    visit run_summary_path(run)
    assert_no_page_overflow
  end

  test "the run summary page shows every stat row at phone widths" do
    account = accounts(:one)
    sign_in_as(account.email_address, "password")
    run = account.runs.create!(mission: "Ship alpha", pack_kind: "two-pack", status: "finished",
      started_at: 2.days.ago, ended_at: 1.day.ago)

    page.current_window.resize_to(320, 667)
    visit run_summary_path(run)

    assert_text "Completed"
    assert_text "Cards completed"
    assert_text "Total cost"
    assert_text "Resolved failures"
    assert_text "Open failures"
    assert_no_page_overflow
  end

  private

    def assert_no_page_overflow
      assert page.evaluate_script("document.documentElement.scrollWidth <= document.documentElement.clientWidth"),
        "expected page content to fit within the viewport width"
    end
end
