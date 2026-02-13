class AddParTotalAndDiffParToTeamScores < ActiveRecord::Migration[8.1]
  def change
    add_column :team_scores, :par_total, :integer, default: 0, null: false
    add_column :team_scores, :diff_par, :integer, default: 0, null: false
  end
end
