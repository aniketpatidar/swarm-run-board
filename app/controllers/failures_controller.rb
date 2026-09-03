# frozen_string_literal: true

class FailuresController < ApplicationController
  def resolve
    run = Current.account.runs.find(params[:run_id])
    @failure = run.failures.find(params[:id])
    @failure.resolve!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to run_path(run) }
    end
  end

  def reassign
    run = Current.account.runs.find(params[:run_id])
    @failure = run.failures.find(params[:id])
    @failure.reassign!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to run_path(run) }
    end
  end
end
