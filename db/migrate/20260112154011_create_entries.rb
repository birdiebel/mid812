class CreateEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :entries do |t|
      t.references :event, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.references :licence
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
