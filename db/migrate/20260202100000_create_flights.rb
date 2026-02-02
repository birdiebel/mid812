class CreateFlights < ActiveRecord::Migration[8.1]
  def change
    create_table :flights do |t|
      t.references :config_teetime, null: false, foreign_key: true
      t.integer :num
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
