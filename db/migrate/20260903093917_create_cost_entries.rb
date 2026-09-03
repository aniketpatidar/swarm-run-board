class CreateCostEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :cost_entries do |t|
      t.references :run, null: false, foreign_key: true
      t.string :role
      t.integer :tokens_in, null: false, default: 0
      t.integer :tokens_out, null: false, default: 0
      t.decimal :cost, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
