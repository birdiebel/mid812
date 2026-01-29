class CreatePlayercats < ActiveRecord::Migration[8.1]
  def change
    create_table :playercats do |t|
      t.string :name, null: false
      t.references :agecat, null: false, foreign_key: true
      t.integer :sexe, default: 0
      t.decimal :hcp_min, precision: 3, scale: 1
      t.decimal :hcp_max, precision: 3, scale: 1
      t.string :version, null: false
      t.integer :teebox, default: 0
      t.integer :priority, default: 0
      t.boolean :actif, default: true

      t.timestamps
    end
  end
end
