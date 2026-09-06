# frozen_string_literal: true

# Shared behavior for failure actions
module Failures::Actionable
  extend ActiveSupport::Concern

  included do
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
      @failure ||= run.failures.find(params[:failure_id])
    end

    def run
      @run ||= Current.account.runs.find(params[:run_id])
    end
  end
end
