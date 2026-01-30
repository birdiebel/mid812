class AddMinMaxPlayersToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :min_players, :integer, default: 1
    add_column :events, :max_players, :integer, default: 1
  end
end
