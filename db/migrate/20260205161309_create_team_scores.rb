class CreateTeamScores < ActiveRecord::Migration[8.1]
  def change
    create_table :team_scores do |t|
      t.references :team, null: false, foreign_key: true
      t.references :round, null: false, foreign_key: true
      t.integer :hole_played, default: 0
      t.integer :status, default: 0
      t.integer :brut_total, default: 0
      t.integer :net_total, default: 0
      t.integer :stb_total, default: 0
      t.integer :stroke_play_score, default: 0

      t.timestamps
    end

    add_index :team_scores, [ :team_id, :round_id ], unique: true
  end
end
