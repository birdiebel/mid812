class CreateAgecats < ActiveRecord::Migration[8.1]
  def change
    create_table :agecats do |t|
      t.string :name, null: false
      t.string :short, null: false
      t.integer :age_low, default: 0
      t.integer :age_high, default: 99
      t.string :color, null: false
      t.integer :year, default: Date.today.year

      t.timestamps
    end
  end
end
