class CreateTees < ActiveRecord::Migration[8.1]
  def change
    create_table :tees do |t|
      t.references :course
      t.string :par_str, null: false
      t.string :dist_str, null: false
      t.string :stroke_str, null: false
      t.integer :slope,  null: false, default: 121
      t.decimal :rating, precision: 3, scale: 1, default: 72
      t.integer :teebox, default: 1

      t.timestamps
    end
  end
end
