class AddNbCardsToFormulas < ActiveRecord::Migration[8.1]
  def change
    add_column :formulas, :nb_cards, :integer, default: 1
  end
end
