# frozen_string_literal: true

class AgentMessagesController < ApplicationController
  def create
    @run = Current.account.runs.find(params[:run_id])
    @message = @run.agent_messages.new(message_params)

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to run_path(@run) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { redirect_to run_path(@run), status: :see_other }
      end
    end
  end

  private
    def message_params
      params.expect(agent_message: [ :body, :to_role ]).merge(from_role: "operator")
    end
end
