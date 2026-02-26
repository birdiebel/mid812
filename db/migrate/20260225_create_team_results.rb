class CreateTeamResults < ActiveRecord::Migration[7.0]
  def change
    create_table :team_results do |t|
      t.references :event, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.integer :par
      t.integer :brut
      t.integer :net
      t.integer :stb
      t.integer :position
      t.integer :points
      t.timestamps
    end
  end
end
