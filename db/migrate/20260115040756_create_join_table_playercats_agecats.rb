class CreateJoinTablePlayercatsAgecats < ActiveRecord::Migration[8.1]
  def change
    create_join_table :playercats, :agecats do |t|
      # t.index [:playercat_id, :agecat_id]
      # t.index [:agecat_id, :playercat_id]
    end
  end
end
