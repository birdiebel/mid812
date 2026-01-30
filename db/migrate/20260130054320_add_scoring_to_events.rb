class AddScoringToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :scoring, :integer, default: 0
  end
end
