# frozen_string_literal: true

class CostEntriesController < ApplicationController
  def create
    load_entry
    @entry.save
    redirect_or_stream
  end

  private
    def load_entry
      @run = Current.account.runs.find(params[:run_id])
      @entry = @run.cost_entries.new(entry_params)
    end

    def redirect_or_stream
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to run_path(@run), status: redirect_status }
      end
    end

    def redirect_status
      @entry.persisted? ? :found : :see_other
    end

    def entry_params
      params.expect(cost_entry: [ :role, :tokens_in, :tokens_out, :cost ])
    end
end
