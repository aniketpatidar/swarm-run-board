# frozen_string_literal: true

class FailuresController < ApplicationController
  def resolve
    failure.resolve!
    respond_for
  end

  def reassign
    failure.reassign!
    respond_for
  end

  private

  def respond_for
    respond_to do |format|
      format.turbo_stream { render turbo_stream: refresh }
      format.html { redirect_to run_path(run) }
    end
  end

  def refresh
    [
      turbo_stream.replace("triage_queue", partial: "failures/triage", locals: { run: run }),
      turbo_stream.replace("audit_trail", partial: "failures/audit", locals: { run: run })
    ]
  end

  def failure
    @failure ||= run.failures.find(params[:id])
  end

  def run
    @run ||= Current.account.runs.find(params[:run_id])
  end
end
