class CreateLicences < ActiveRecord::Migration[8.1]
  def change
    create_table :licences do |t|
      t.references :player
      t.string :num
      t.decimal :hcp, precision: 3, scale: 1
      t.string :club
      t.boolean :actif, default: true

      t.timestamps
    end
    add_index :licences, :num, unique: true
  end
end
