# frozen_string_literal: true

class AgentMessagesController < ApplicationController
  def create
    @run = Current.account.runs.find(params[:run_id])
    @message = @run.agent_messages.new(message_params)
    @message.save

    respond_to_creation
  end

  private
    def respond_to_creation
      respond_to do |format|
        format.turbo_stream { render status: turbo_status }
        format.html { redirect_to run_path(@run), status: redirect_status }
      end
    end

    def turbo_status
      @message.persisted? ? :ok : :unprocessable_entity
    end

    def redirect_status
      @message.persisted? ? :found : :see_other
    end

    def message_params
      params.expect(agent_message: [ :body, :to_role ]).merge(from_role: "operator")
    end
end
