class CreateSlots < ActiveRecord::Migration[8.1]
  def change
    create_table :slots do |t|
      t.references :flight, null: false, foreign_key: true
      t.references :team, foreign_key: true
      t.integer :num
      t.decimal :playing_hcp, precision: 4, scale: 1

      t.timestamps
    end
  end
end
