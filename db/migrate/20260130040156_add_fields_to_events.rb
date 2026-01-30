class AddFieldsToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :type, :integer
    add_column :events, :fee, :decimal, precision: 8, scale: 2
    add_column :events, :fee_member, :decimal, precision: 8, scale: 2
    add_column :events, :actif_round, :integer
  end
end
