# frozen_string_literal: true

require "test_helper"

class AgentMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    sign_in_as(@account)
  end

  test "create adds a message to the run with operator as from_role" do
    run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")

    assert_difference -> { run.agent_messages.count } => 1 do
      post run_agent_messages_path(run),
        params: { agent_message: { body: "Verification passed.", to_role: "coder" } },
        as: :turbo_stream
    end

    message = run.agent_messages.last
    assert_equal "operator", message.from_role
    assert_equal "coder", message.to_role
    assert_equal "Verification passed.", message.body
  end

  test "create on a run in another account returns 404" do
    run = accounts(:two).runs.create!(mission: "Other", pack_kind: "two-pack")

    assert_no_difference -> { run.agent_messages.count } do
      post run_agent_messages_path(run),
        params: { agent_message: { body: "Nope", to_role: "coder" } },
        as: :turbo_stream
    end
    assert_response :not_found
  end

  test "create with invalid params returns unprocessable entity" do
    run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")

    assert_no_difference -> { run.agent_messages.count } do
      post run_agent_messages_path(run),
        params: { agent_message: { body: "", to_role: "" } },
        as: :turbo_stream
    end
    assert_response :unprocessable_entity
  end
end
