class AddFormatToPlayercat < ActiveRecord::Migration[8.1]
  def change
    add_column :playercats, :format, :integer, default: 0
  end
end
