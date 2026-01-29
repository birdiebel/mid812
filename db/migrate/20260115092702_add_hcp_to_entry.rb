class AddHcpToEntry < ActiveRecord::Migration[8.1]
  def change
    add_column :entries, :hcp, :decimal, precision: 3, scale: 1
  end
end
