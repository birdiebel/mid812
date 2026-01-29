class AddFormatToEvent < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :format, :integer, default: 0
  end
end
