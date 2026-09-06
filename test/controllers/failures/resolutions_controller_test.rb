# frozen_string_literal: true

require "test_helper"

class Failures::ResolutionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    sign_in_as(@account)
  end

  test "resolving a failure sets resolved_at and records an audit entry" do
    run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")
    failure = run.failures.create!(title: "Canceled run", severity: "low")

    assert_difference -> { run.audit_entries.count } => 1 do
      post run_failure_resolution_path(run, failure), as: :turbo_stream
    end

    assert_not_nil failure.reload.resolved_at
    assert_equal "resolved", run.audit_entries.last.action
  end

  test "resolving a failure in another account returns 404" do
    run = accounts(:two).runs.create!(mission: "Other", pack_kind: "two-pack")
    failure = run.failures.create!(title: "Nope", severity: "high")

    assert_no_difference -> { run.audit_entries.count } do
      post run_failure_resolution_path(run, failure), as: :turbo_stream
    end
    assert_response :not_found
  end
end
