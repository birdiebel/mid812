class AddTeamToEntries < ActiveRecord::Migration[8.1]
  def change
    add_reference :entries, :team, foreign_key: true
  end
end
