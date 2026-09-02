# frozen_string_literal: true

require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include AuthenticationHelper

  driven_by :cuprite, using: :chrome, options: { browser_path: "/usr/bin/google-chrome", timeout: 10 }
end
