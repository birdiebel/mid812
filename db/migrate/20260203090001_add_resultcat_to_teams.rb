class AddResultcatToTeams < ActiveRecord::Migration[8.1]
  def change
    add_reference :teams, :resultcat, foreign_key: true
  end
end
