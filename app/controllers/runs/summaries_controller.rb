# frozen_string_literal: true

class Runs::SummariesController < ApplicationController
  def show
    @run = Current.account.runs.find(params[:run_id])
  end
end
