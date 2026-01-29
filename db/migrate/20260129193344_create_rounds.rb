class CreateRounds < ActiveRecord::Migration[8.1]
  def change
    create_table :rounds do |t|
      t.references :event, null: false, foreign_key: true
      t.date :date
      t.integer :status

      t.timestamps
    end
  end
end
