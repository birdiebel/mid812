class AddFormulaToConfigTeetimes < ActiveRecord::Migration[8.1]
  def change
    add_reference :config_teetimes, :formula, foreign_key: true
  end
end
