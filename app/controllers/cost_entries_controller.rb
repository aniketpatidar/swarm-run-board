# frozen_string_literal: true

class CostEntriesController < ApplicationController
  def create
    load_entry

    if @entry.save
      render_success
    else
      render_failure
    end
  end

  private
    def load_entry
      @run = Current.account.runs.find(params[:run_id])
      @entry = @run.cost_entries.new(entry_params)
    end

    def render_success
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to run_path(@run) }
      end
    end

    def render_failure
      respond_to do |format|
        format.turbo_stream { replace_rollup }
        format.html { redirect_to run_path(@run), status: :see_other }
      end
    end

    def replace_rollup
      turbo_stream.replace("cost_rollup", "")
    end

    def entry_params
      params.expect(cost_entry: [ :role, :tokens_in, :tokens_out, :cost ])
    end
end
