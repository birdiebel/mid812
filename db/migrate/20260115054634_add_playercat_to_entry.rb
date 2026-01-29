class AddPlayercatToEntry < ActiveRecord::Migration[8.1]
  def change
    add_reference :entries, :playercat, foreign_key: true
  end
end
