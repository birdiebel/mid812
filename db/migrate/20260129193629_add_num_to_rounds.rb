class AddNumToRounds < ActiveRecord::Migration[8.1]
  def change
    add_column :rounds, :num, :integer
  end
end
