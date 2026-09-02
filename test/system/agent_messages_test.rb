# frozen_string_literal: true

require "application_system_test_case"

class AgentMessagesTest < ApplicationSystemTestCase
  test "a run detail page shows agent messages with from, to, body, and card link" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    run = account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack", status: "running", started_at: 1.day.ago)
    card = run.cards.create!(name: "Run board index", current_role: "coder", position: 1)
    run.agent_messages.create!(from_role: "specifier", to_role: "coder", body: "Spec is ready, please implement.", card: card)

    visit run_path(run)

    within("#agent_messages") do
      assert_text "specifier"
      assert_text "coder"
      assert_text "Spec is ready, please implement."
      assert_link "Run board index"
    end
  end

  test "posting a new message adds it to the run detail page without a full reload" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    run = account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack", status: "running", started_at: 1.day.ago)

    visit run_path(run)
    fill_in "Message", with: "Verification passed for the index page."
    select "coder", from: "To role"
    click_on "Post message"

    within("#agent_messages") do
      assert_text "Verification passed for the index page."
    end
  end

  test "agent messages are read-only and cannot be edited inline" do
    account = Account.create!(name: "Ops", email_address: "ops@example.com", password: "password123")
    sign_in_as("ops@example.com", "password123")

    run = account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack", status: "running", started_at: 1.day.ago)
    run.agent_messages.create!(from_role: "coder", to_role: "cleaner", body: "Handing off for cleanup.", card: nil)

    visit run_path(run)

    within("#agent_messages") do
      assert_no_selector "form[action*='messages'][method='patch']"
      assert_no_button "Edit"
    end
  end
end
