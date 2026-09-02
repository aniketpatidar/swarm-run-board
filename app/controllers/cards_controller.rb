# frozen_string_literal: true

class CardsController < ApplicationController
  def advance
    run = Current.account.runs.find(params[:run_id])
    @card = run.cards.find(params[:id])
    @card.advance!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to run_path(run) }
    end
  end
end
