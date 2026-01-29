class CreateTours < ActiveRecord::Migration[8.1]
  def change
    create_table :tours do |t|
      t.string :name, null: false
      t.integer :status, default: 0
      t.boolean :actif, default: true

      t.timestamps
    end
  end
end
