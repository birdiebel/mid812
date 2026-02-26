class Admin::RoundStatusesController < ApplicationController
  before_action :set_round

  def update
    if Round.statuses.keys.include?(params[:status])
      @round.update(status: params[:status])
      render json: { success: true, status: @round.status }
    else
      render json: { success: false, error: "Invalid status" }, status: :unprocessable_entity
    end
  end

  private

    def set_round
      @round = Round.find(params[:id])
    end
end
