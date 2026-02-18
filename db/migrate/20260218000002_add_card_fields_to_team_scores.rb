class AddCardFieldsToTeamScores < ActiveRecord::Migration[8.1]
  def change
    add_column :team_scores, :start_hole, :integer
    add_column :team_scores, :playing_hcp, :integer
    add_column :team_scores, :brut_str, :string
    add_column :team_scores, :net_str, :string
    add_column :team_scores, :stb_str, :string
    add_column :team_scores, :recu_str, :string
  end
end
