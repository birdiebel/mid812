module Api
  module V1
    class SlotsController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [ :update ]
      before_action :authenticate_user!

      def update
        @slot = Slot.find(params[:id])

        if @slot.update(slot_params)
          render json: {
            success: true,
            slot: @slot.as_json(include: {
              entry: {
                include: [ :player, :team, :playercat ]
              }
            })
          }, status: :ok
        else
          render json: { success: false, errors: @slot.errors }, status: :unprocessable_entity
        end
      end

      private

      def slot_params
        params.require(:slot).permit(:entry_id)
      end
    end
  end
end
