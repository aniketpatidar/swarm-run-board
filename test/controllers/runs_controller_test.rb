# frozen_string_literal: true

require "test_helper"

class RunsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    sign_in_as(@account)
  end

  test "index requires authentication" do
    sign_out
    get root_path
    assert_redirected_to new_session_path
  end

  test "index lists the current account's runs" do
    @account.runs.create!(mission: "Ship alpha", pack_kind: "two-pack")
    other = accounts(:two)
    other.runs.create!(mission: "Other account run", pack_kind: "six-pack")

    get root_path
    assert_response :success
    assert_select "#runs" do
      assert_select "tr", text: /Ship alpha/
      assert_select "tr", text: /two-pack/
      assert_select "tr", text: /running/
    end
    assert_no_match /Other account run/, @response.body
  end

  test "create requires authentication" do
    sign_out
    assert_no_difference "Run.count" do
      post runs_path, params: { run: { mission: "Hack", pack_kind: "two-pack" } }
    end
    assert_redirected_to new_session_path
  end

  test "create adds a run to the current account in running state" do
    assert_difference -> { @account.runs.count } => 1 do
      post runs_path, params: { run: { mission: "Triage weekend", pack_kind: "six-pack" } }, as: :turbo_stream
    end

    run = @account.runs.last
    assert_equal "running", run.status
    assert_equal "six-pack", run.pack_kind
    assert response.body.include?("Triage weekend")
  end

  test "create with invalid params re-renders the form" do
    assert_no_difference "Run.count" do
      post runs_path, params: { run: { mission: "", pack_kind: "two-pack" } }
    end
    assert_response :unprocessable_entity
  end
end
