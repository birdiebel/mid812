class RenameTypeToEventTypeInEvents < ActiveRecord::Migration[8.1]
  def change
    rename_column :events, :type, :event_type
  end
end
