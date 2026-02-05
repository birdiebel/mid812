module Api
  module V1
    class SlotsController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [ :update ]
      before_action :authenticate_user!

      puts "V1::SlotsController loaded"

      def update
        @slot = Slot.find(params[:id])

        if @slot.update(slot_params)
          # Reload to get the updated playing_hcp from callbacks
          @slot.reload

          render json: {
          success: true,
          slot: @slot.as_json(include: {
            team: {
              methods: [ :team_name, :total_hcp ],
              include: {
                entries: {
                  include: {
                    player: {},
                    playercat: { methods: [ :icon_teebox ] },
                    licence: {}
                  }
                },
                resultcat: {}
              }
            }
          })
        }, status: :ok
        else
          render json: { success: false, errors: @slot.errors }, status: :unprocessable_entity
        end
      end

      private

      def slot_params
        params.require(:slot).permit(:team_id)
      end
    end
  end
end
