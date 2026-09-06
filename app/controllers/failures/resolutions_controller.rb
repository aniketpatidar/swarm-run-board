# frozen_string_literal: true

class Failures::ResolutionsController < ApplicationController
  def create
    failure.resolve!
    respond_for
  end
  include Failures::Actionable
end
