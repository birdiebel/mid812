class RemovePlayingHcpFromEntries < ActiveRecord::Migration[8.1]
  def change
    remove_column :entries, :playing_hcp, :integer
  end
end
