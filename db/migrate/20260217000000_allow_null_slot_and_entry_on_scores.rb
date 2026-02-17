class AllowNullSlotAndEntryOnScores < ActiveRecord::Migration[8.1]
  def change
    change_column_null :scores, :slot_id, true
    change_column_null :scores, :entry_id, true
  end
end
