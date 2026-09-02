# frozen_string_literal: true

require "application_system_test_case"

class FailureTriageTest < ApplicationSystemTestCase
  test "failures appear in the triage queue with severity and affected target" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    run = account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack", status: "failed", started_at: 1.day.ago)
    card = run.cards.create!(name: "Run board index", current_role: "coder", position: 1)
    run.failures.create!(title: "Test suite failing", severity: "high", card: card)

    visit run_path(run)

    within("#triage_queue") do
      assert_text "Test suite failing"
      assert_text "high"
      assert_link "Run board index"
    end
  end

  test "resolving a failure removes it from the queue and retains an audit trail" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    run = account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack", status: "running", started_at: 1.day.ago)
    run.failures.create!(title: "Canceled run", severity: "low")

    visit run_path(run)
    within("#triage_queue") do
      click_on "Resolve"
    end

    within("#triage_queue") do
      assert_no_text "Canceled run"
    end

    within("#audit_trail") do
      assert_text "resolved"
      assert_text "Canceled run"
    end
  end

  test "reassigning a failure leaves it in the queue with a retained audit trail" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    run = account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack", status: "running", started_at: 1.day.ago)
    run.failures.create!(title: "Stuck card", severity: "medium")

    visit run_path(run)
    within("#triage_queue") do
      click_on "Reassign"
    end

    assert_text "Stuck card"
    within("#audit_trail") do
      assert_text "reassigned"
      assert_text "Stuck card"
    end
  end
end
