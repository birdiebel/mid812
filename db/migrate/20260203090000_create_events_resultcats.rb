class CreateEventsResultcats < ActiveRecord::Migration[8.1]
  def change
    create_table :events_resultcats do |t|
      t.references :event, null: false, foreign_key: true
      t.references :resultcat, null: false, foreign_key: true
      t.timestamps
    end

    add_index :events_resultcats, [ :event_id, :resultcat_id ], unique: true
  end
end
