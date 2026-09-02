class CreateRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :runs do |t|
      t.references :account, null: false, foreign_key: true
      t.text :mission
      t.string :pack_kind, null: false, default: "two-pack"
      t.string :status, null: false, default: "running"
      t.datetime :started_at, null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end
  end
end
