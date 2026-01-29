class AddActifToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :actif, :boolean, default: true
  end
end
