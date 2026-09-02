class CreateCards < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.references :run, null: false, foreign_key: true
      t.string :name, null: false
      t.string :current_role, null: false
      t.integer :position, null: false

      t.timestamps
    end
  end
end
