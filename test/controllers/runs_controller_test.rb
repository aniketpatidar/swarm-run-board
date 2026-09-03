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
    assert_select "turbo-stream[action=append][target=runs_rows]" do
      assert_select "tr", text: /Triage weekend/
    end
  end

  test "create with invalid params re-renders the form" do
    assert_no_difference "Run.count" do
      post runs_path, params: { run: { mission: "", pack_kind: "two-pack" } }
    end
    assert_response :unprocessable_entity
  end

  test "show lists the run's cards in position order" do
    run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")
    run.cards.create!(name: "Run board index", current_role: "coder", position: 1)
    run.cards.create!(name: "Summary page", current_role: "blocked", position: 2)

    get run_path(run)
    assert_response :success
    assert_select "#cards" do
      assert_select "li", text: /Run board index/
      assert_select "li", text: /coder/
      assert_select "li", text: /Summary page/
      assert_select "li", text: /blocked/
    end
  end

  test "show lists the run's agent messages with from, to, body, and card link" do
    run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")
    card = run.cards.create!(name: "Run board index", current_role: "coder", position: 1)
    run.agent_messages.create!(from_role: "specifier", to_role: "coder", body: "Spec is ready.", card: card)

    get run_path(run)
    assert_response :success
    assert_select "#agent_messages" do
      assert_select "li", text: /specifier/
      assert_select "li", text: /coder/
      assert_select "li", text: /Spec is ready\./
      assert_select "a", text: "Run board index"
    end
  end

  test "show returns 404 for a run in another account" do
    run = accounts(:two).runs.create!(mission: "Other", pack_kind: "two-pack")
    get run_path(run)
    assert_response :not_found
  end

  test "advance moves a card to the next lane" do
    run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")
    card = run.cards.create!(name: "Run board index", current_role: "specifier", position: 1)

    post advance_run_card_path(run, card), as: :turbo_stream
    assert_response :success
    assert_equal "coder", card.reload.current_role
  end

  test "advance on a card in another account returns 404" do
    run = accounts(:two).runs.create!(mission: "Other", pack_kind: "two-pack")
    card = run.cards.create!(name: "Run board index", current_role: "specifier", position: 1)

    post advance_run_card_path(run, card), as: :turbo_stream
    assert_response :not_found
  end
end
