class CreateFailures < ActiveRecord::Migration[8.1]
  def change
    create_table :failures do |t|
      t.references :run, null: false, foreign_key: true
      t.references :card, foreign_key: true
      t.string :title, null: false
      t.string :severity, null: false
      t.datetime :resolved_at

      t.timestamps
    end
    add_index :failures, [ :run_id, :resolved_at ]
  end
end
