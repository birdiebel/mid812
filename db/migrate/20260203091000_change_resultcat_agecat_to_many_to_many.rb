class ChangeResultcatAgecatToManyToMany < ActiveRecord::Migration[8.1]
  def up
    # Remove the old belongs_to relationship
    remove_reference :resultcats, :agecat, foreign_key: true

    # Create the join table for many-to-many
    create_join_table :resultcats, :agecats do |t|
      t.index [ :resultcat_id, :agecat_id ]
      t.index [ :agecat_id, :resultcat_id ]
    end
  end

  def down
    # Drop the join table
    drop_join_table :resultcats, :agecats

    # Re-add the belongs_to relationship
    add_reference :resultcats, :agecat, foreign_key: true
  end
end
