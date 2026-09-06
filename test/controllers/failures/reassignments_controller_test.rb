# frozen_string_literal: true

require "test_helper"

class Failures::ReassignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    sign_in_as(@account)
  end

  test "reassigning a failure leaves it open and records an audit entry" do
    run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")
    failure = run.failures.create!(title: "Stuck card", severity: "medium")

    assert_difference -> { run.audit_entries.count } => 1 do
      post run_failure_reassignment_path(run, failure), as: :turbo_stream
    end

    assert_nil failure.reload.resolved_at
    assert_equal "reassigned", run.audit_entries.last.action
  end
end
