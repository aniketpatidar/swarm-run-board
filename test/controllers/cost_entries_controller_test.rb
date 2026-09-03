# frozen_string_literal: true

require "test_helper"

class CostEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    sign_in_as(@account)
  end

  test "create adds a cost entry to the run" do
    run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")

    assert_difference -> { run.cost_entries.count } => 1 do
      post run_cost_entries_path(run),
        params: { cost_entry: { role: "specifier", tokens_in: 400, tokens_out: 100, cost: 5.00 } },
        as: :turbo_stream
    end

    entry = run.cost_entries.last
    assert_equal "specifier", entry.role
    assert_equal 400, entry.tokens_in
    assert_equal 100, entry.tokens_out
    assert_equal 5.00, entry.cost.to_f
  end

  test "create on a run in another account returns 404" do
    run = accounts(:two).runs.create!(mission: "Other", pack_kind: "two-pack")

    assert_no_difference -> { run.cost_entries.count } do
      post run_cost_entries_path(run),
        params: { cost_entry: { role: "specifier", tokens_in: 400, tokens_out: 100, cost: 5.00 } },
        as: :turbo_stream
    end
    assert_response :not_found
  end

  test "an invalid entry re-renders the rollup with the entry's errors instead of blanking it" do
    run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")
    run.cost_entries.create!(role: "coder", tokens_in: 600, tokens_out: 200, cost: 7.50)

    assert_no_difference -> { run.cost_entries.count } do
      post run_cost_entries_path(run),
        params: { cost_entry: { role: "specifier", tokens_in: 400, tokens_out: 100, cost: "" } },
        as: :turbo_stream
    end

    body = CGI.unescapeHTML(@response.body)
    assert_includes body, 'id="cost_rollup"'
    assert_includes body, "Cost can't be blank"
    assert_includes body, "7.50"
    refute_match(/<turbo-stream action="replace" target="cost_rollup">\s*<template>\s*<\//, @response.body)
  end
end
