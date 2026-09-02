# frozen_string_literal: true

class RunsController < ApplicationController
  def index
    @runs = Current.account.runs.order(created_at: :desc)
  end

  def new
    @run = Current.account.runs.new
  end

  def create
    @run = Current.account.runs.new(run_params)

    if @run.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to root_path, notice: "Run created." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def run_params
      params.expect(run: [ :mission, :pack_kind ])
    end
end
