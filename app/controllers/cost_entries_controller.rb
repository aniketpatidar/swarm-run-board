# frozen_string_literal: true

class CostEntriesController < ApplicationController
  def create
    @run = Current.account.runs.find(params[:run_id])
    @entry = @run.cost_entries.new(entry_params)

    if @entry.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to run_path(@run) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("cost_rollup", "") }
        format.html { redirect_to run_path(@run), status: :see_other }
      end
    end
  end

  private
    def entry_params
      params.expect(cost_entry: [ :role, :tokens_in, :tokens_out, :cost ])
    end
end
