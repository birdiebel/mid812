class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.string :firstname, null: false
      t.string :lastname, null: false
      t.date :dob, null: false, default: "1970/01/01"
      t.integer :sexe, default: 0
      t.integer :lang, default: 0
      t.references :user, null: true

      t.timestamps
    end
  end
end
