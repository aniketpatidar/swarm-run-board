# frozen_string_literal: true

require "test_helper"
require "mutant/minitest/coverage"

class ApplicationHelperTest < ActionView::TestCase
  cover "ApplicationHelper#*"
  test "run status badge variant maps known statuses" do
    assert_equal :info, run_status_badge_variant("running")
    assert_equal :success, run_status_badge_variant("finished")
    assert_equal :error, run_status_badge_variant("failed")
    assert_equal :warning, run_status_badge_variant("aborted")
  end

  test "run status badge variant falls back to default for unknown status" do
    assert_equal :default, run_status_badge_variant("queued")
  end

  test "failure severity badge variant maps known severities" do
    assert_equal :error, failure_severity_badge_variant("high")
    assert_equal :warning, failure_severity_badge_variant("medium")
    assert_equal :default, failure_severity_badge_variant("low")
  end

  test "failure severity badge variant falls back to default for unknown severity" do
    assert_equal :default, failure_severity_badge_variant("critical")
  end

  test "card role badge variant maps known roles" do
    assert_equal :default, card_role_badge_variant("specifier")
    assert_equal :info, card_role_badge_variant("coder")
    assert_equal :success, card_role_badge_variant("cleaner")
    assert_equal :info, card_role_badge_variant("architect")
    assert_equal :warning, card_role_badge_variant("hardender")
    assert_equal :warning, card_role_badge_variant("qa")
    assert_equal :success, card_role_badge_variant("done")
    assert_equal :error, card_role_badge_variant("blocked")
  end

  test "card role badge variant falls back to default for unknown role" do
    assert_equal :default, card_role_badge_variant("plumber")
  end
end
