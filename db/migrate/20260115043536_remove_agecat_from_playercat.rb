class RemoveAgecatFromPlayercat < ActiveRecord::Migration[8.1]
  def change
    remove_reference :playercats, :agecat, null: false, foreign_key: true
  end
end
