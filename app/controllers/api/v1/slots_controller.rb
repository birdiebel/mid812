module Api
  module V1
    class SlotsController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [ :update ]
      before_action :authenticate_user!

      puts "V1::SlotsController loaded"

      def update
        @slot = Slot.find(params[:id])
        previous_team_id = @slot.team_id

        if @slot.update(slot_params)
          sync_scores_after_slot_update(previous_team_id)

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

        def sync_scores_after_slot_update(previous_team_id)
          round = @slot.flight&.config_teetime&.round
          return unless round

          current_team_id = @slot.team_id

          sync_team_scores_for_round(previous_team_id, round) if previous_team_id.present?
          sync_team_scores_for_round(current_team_id, round) if current_team_id.present? && current_team_id != previous_team_id
        end

        def sync_team_scores_for_round(team_id, round)
          team = Team.includes(:entries).find_by(id: team_id)
          return unless team

          entry_ids = team.entries.pluck(:id)
          return if entry_ids.empty?

          team_slot = Slot.joins(flight: :config_teetime)
                          .where(team_id: team.id, config_teetimes: { round_id: round.id })
                          .first

          if team_slot
            Score.where(round_id: round.id, entry_id: entry_ids)
                 .update_all(slot_id: team_slot.id, updated_at: Time.current)
          else
            Score.where(round_id: round.id, entry_id: entry_ids)
                 .update_all(slot_id: nil, updated_at: Time.current)
          end
        end

        def slot_params
          params.require(:slot).permit(:team_id)
        end
    end
  end
end
