class Admin::DashboardEventsController < ApplicationController
  def show
    @event = Event.find(params[:id])
    render partial: "admin/events/dashboard/event", locals: { event: @event }
  end
end
