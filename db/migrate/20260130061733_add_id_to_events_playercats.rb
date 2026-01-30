class AddIdToEventsPlayercats < ActiveRecord::Migration[8.1]
  def up
    # Remove existing table and recreate with id
    drop_table :events_playercats

    create_table :events_playercats do |t|
      t.references :event, null: false, foreign_key: true
      t.references :playercat, null: false, foreign_key: true
      t.integer :scoring
      t.timestamps
    end

    add_index :events_playercats, [ :event_id, :playercat_id ], unique: true
  end

  def down
    drop_table :events_playercats

    create_table :events_playercats, id: false do |t|
      t.references :event, null: false, foreign_key: true
      t.references :playercat, null: false, foreign_key: true
      t.integer :scoring
    end

    add_index :events_playercats, [ :event_id, :playercat_id ]
  end
end
