class BackfillScoresSlotAndEntryConsistency < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    say_with_time "Backfilling scores slot/entry consistency" do
      Score.includes(:round, entry: :team).find_each do |score|
        next unless score.round

        team = score.entry&.team

        if team.nil?
          score.update_columns(slot_id: nil, entry_id: nil, updated_at: Time.current)
          next
        end

        slot = Slot.joins(flight: :config_teetime)
                   .where(team_id: team.id, config_teetimes: { round_id: score.round_id })
                   .first

        if slot
          score.update_columns(slot_id: slot.id, updated_at: Time.current)
        else
          score.update_columns(slot_id: nil, entry_id: nil, updated_at: Time.current)
        end
      end
    end
  end

  def down
    # no-op
  end
end
