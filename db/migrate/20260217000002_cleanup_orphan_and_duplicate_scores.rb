class CleanupOrphanAndDuplicateScores < ActiveRecord::Migration[8.1]
  def up
    say_with_time "Removing orphan scores without entry" do
      Score.where(entry_id: nil).delete_all
    end

    say_with_time "Removing duplicate scores per [round_id, entry_id]" do
      duplicates = Score.where.not(entry_id: nil)
                        .group(:round_id, :entry_id)
                        .having("COUNT(*) > 1")
                        .count

      duplicates.each_key do |round_id, entry_id|
        keep_id = Score.where(round_id: round_id, entry_id: entry_id)
                       .order(Arel.sql("(slot_id IS NULL) ASC"), :updated_at, :id)
                       .last
                       &.id

        next unless keep_id

        Score.where(round_id: round_id, entry_id: entry_id)
             .where.not(id: keep_id)
             .delete_all
      end
    end

    add_index :scores, [ :round_id, :entry_id ], unique: true, where: "entry_id IS NOT NULL", name: "index_scores_on_round_id_and_entry_id_unique"
  end

  def down
    remove_index :scores, name: "index_scores_on_round_id_and_entry_id_unique"
  end
end
