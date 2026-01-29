class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.references :club
      t.string :version, null: false
      t.integer :nb_hole, null: false, default: 18

      t.timestamps
    end
    add_index :courses, :name, unique: true
  end
end
