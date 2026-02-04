class AddNumToTeams < ActiveRecord::Migration[8.1]
  def change
    add_column :teams, :num, :integer
    add_index :teams, [ :event_id, :num ], unique: true
  end
end
