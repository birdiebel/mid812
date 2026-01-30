class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
