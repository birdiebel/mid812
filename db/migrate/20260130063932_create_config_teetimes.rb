class CreateConfigTeetimes < ActiveRecord::Migration[8.1]
  def change
    create_table :config_teetimes do |t|
      t.references :round, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :start_hole
      t.integer :nb_slots
      t.integer :step, default: 10
      t.integer :nb_teams
      t.time :start_time, default: '08:00:00'

      t.timestamps
    end
  end
end
