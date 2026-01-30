class CreateFormulas < ActiveRecord::Migration[8.1]
  def change
    create_table :formulas do |t|
      t.string :name, null: false
      t.integer :format, default: 0
      t.integer :min_players, default: 1
      t.integer :max_players, default: 1

      t.timestamps
    end
  end
end
