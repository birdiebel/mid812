class AddScoringToResultcats < ActiveRecord::Migration[8.1]
  def change
    add_column :resultcats, :scoring, :integer, default: 0
  end
end
