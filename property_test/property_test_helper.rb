# frozen_string_literal: true

require_relative "../test/test_helper"
require "rantly/property"

module PropertyTestSupport
  def property_of(&block)
    Rantly::Property.new(block)
  end
end

ActiveSupport::TestCase.include PropertyTestSupport
