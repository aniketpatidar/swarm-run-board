# frozen_string_literal: true

class Failures::ReassignmentsController < ApplicationController
  def create
    failure.reassign!
    respond_for
  end
  include Failures::Actionable
end
