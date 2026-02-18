class AddTeamAndPlayingHcpToScores < ActiveRecord::Migration[8.1]
  def up
    add_reference :scores, :team, foreign_key: true, null: true
    add_column :scores, :playing_hcp, :integer

    execute <<~SQL
      UPDATE scores AS s
      SET team_id = e.team_id
      FROM entries AS e
      WHERE s.entry_id = e.id
        AND s.team_id IS NULL
    SQL

    execute <<~SQL
      UPDATE scores AS s
      SET team_id = sl.team_id
      FROM slots AS sl
      WHERE s.slot_id = sl.id
        AND s.team_id IS NULL
    SQL

    execute <<~SQL
      UPDATE scores AS s
      SET playing_hcp = e.playing_hcp
      FROM entries AS e
      WHERE s.entry_id = e.id
        AND s.playing_hcp IS NULL
    SQL

    execute <<~SQL
      UPDATE scores AS s
      SET playing_hcp = sl.playing_hcp::integer
      FROM slots AS sl
      WHERE s.slot_id = sl.id
        AND s.playing_hcp IS NULL
    SQL

    add_index :scores, [ :round_id, :team_id ], name: "index_scores_on_round_id_and_team_id"
  end

  def down
    remove_index :scores, name: "index_scores_on_round_id_and_team_id"
    remove_column :scores, :playing_hcp
    remove_reference :scores, :team, foreign_key: true
  end
end
