class UpdateTeamForeignKeyOnDelete < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :entries, :teams
    add_foreign_key :entries, :teams, on_delete: :cascade
  end
end
