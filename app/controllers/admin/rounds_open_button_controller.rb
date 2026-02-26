# frozen_string_literal: true

class Admin::RoundsOpenButtonController < ApplicationController
  def show
    round = Round.find(params[:id])
    render partial: "admin/events/dashboard/round_open_button", locals: { round: round }
  end
end
