class Admin::EventsController < ApplicationController
  before_action :set_event

  def update_status
    if Event.statuses.keys.include?(params[:status])
      @event.update(status: params[:status])
      render json: { success: true, status: @event.status }
    else
      render json: { success: false, error: "Invalid status" }, status: :unprocessable_entity
    end
  end

  private

    def set_event
      @event = Event.find(params[:id])
    end
end
