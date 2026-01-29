class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.integer :status, default: 0
      t.boolean :actif, default: true
      t.references :tour, null: true

      t.timestamps
    end
  end
end
