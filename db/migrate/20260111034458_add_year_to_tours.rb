class AddYearToTours < ActiveRecord::Migration[8.1]
  def change
    add_column :tours, :year, :integer, null: false, default: Time.current.year
  end
end
