class AddScoringToEventsPlayercats < ActiveRecord::Migration[8.1]
  def change
    add_column :events_playercats, :scoring, :integer
  end
end
