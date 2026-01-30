class AddPlayingHcpToEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :entries, :playing_hcp, :integer
  end
end
