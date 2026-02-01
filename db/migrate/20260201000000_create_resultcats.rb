class CreateResultcats < ActiveRecord::Migration[7.0]
  def change
    create_table :resultcats do |t|
      t.string :name, null: false
      t.references :agecat, null: false, foreign_key: true
      t.integer :sexe, default: 0
      t.decimal :hcp_min, precision: 3, scale: 1
      t.decimal :hcp_max, precision: 3, scale: 1
      t.string :version, null: false
      t.integer :priority, default: 0
      t.boolean :actif, default: true

      t.timestamps
    end
  end
end
