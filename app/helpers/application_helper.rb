module ApplicationHelper
  RUN_STATUS_BADGES = {
    "running" => :info,
    "finished" => :success,
    "failed" => :error,
    "aborted" => :warning
  }.freeze

  def run_status_badge_variant(status)
    RUN_STATUS_BADGES.fetch(status, :default)
  end

  FAILURE_SEVERITY_BADGES = {
    "high" => :error,
    "medium" => :warning,
    "low" => :default
  }.freeze

  def failure_severity_badge_variant(severity)
    FAILURE_SEVERITY_BADGES.fetch(severity, :default)
  end

  CARD_ROLE_BADGES = {
    "specifier" => :default,
    "coder" => :info,
    "cleaner" => :success,
    "architect" => :info,
    "hardender" => :warning,
    "qa" => :warning,
    "done" => :success,
    "blocked" => :error
  }.freeze

  def card_role_badge_variant(role)
    CARD_ROLE_BADGES.fetch(role, :default)
  end
end
