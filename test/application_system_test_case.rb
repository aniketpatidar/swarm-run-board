# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include AuthenticationHelper

  driven_by :cuprite
end
