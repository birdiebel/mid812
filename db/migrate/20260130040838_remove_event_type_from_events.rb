class RemoveEventTypeFromEvents < ActiveRecord::Migration[8.1]
  def change
    remove_column :events, :event_type, :integer
  end
end
