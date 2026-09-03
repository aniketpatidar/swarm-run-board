# frozen_string_literal: true

class Cards::AdvancementsController < ApplicationController
  def create
    run = Current.account.runs.find(params[:run_id])
    @card = run.cards.find(params[:card_id])
    @card.advance!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to run_path(run) }
    end
  end
end
