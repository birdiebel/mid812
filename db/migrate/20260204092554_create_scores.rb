class CreateScores < ActiveRecord::Migration[8.1]
  def change
    create_table :scores do |t|
      t.references :round, null: false, foreign_key: true
      t.references :slot, null: false, foreign_key: true
      t.references :entry, null: false, foreign_key: true
      t.integer :status
      t.string :brut_str
      t.string :net_str
      t.string :stb_str
      t.string :recu_str
      t.integer :hole_played
      t.integer :start_hole

      t.timestamps
    end
  end
end
