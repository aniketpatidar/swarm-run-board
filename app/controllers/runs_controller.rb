# frozen_string_literal: true

class RunsController < ApplicationController
  def index
    @runs = Current.account.runs.newest_first
  end

  def new
    @run = Current.account.runs.new
  end

  def create
    @run = Current.account.runs.new(run_params)

    if @run.save
      render_created
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def render_created
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to_for_create }
      end
    end

    def run_params
      params.expect(run: [ :mission, :pack_kind ])
    end

    def redirect_to_for_create
      redirect_to root_path, notice: "Run created."
    end
end
