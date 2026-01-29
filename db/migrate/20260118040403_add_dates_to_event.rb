class AddDatesToEvent < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :date_event, :date, default: -> { 'CURRENT_DATE' }
    add_column :events, :date_open, :date, default: -> { 'CURRENT_DATE' }
    add_column :events, :date_close, :date, default: -> { 'CURRENT_DATE' }
    add_column :events, :nb_rounds, :integer, default: 1
  end
end
