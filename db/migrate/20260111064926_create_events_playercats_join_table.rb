class CreateEventsPlayercatsJoinTable < ActiveRecord::Migration[8.1]
  def change
    create_join_table :events, :playercats
  end
end
