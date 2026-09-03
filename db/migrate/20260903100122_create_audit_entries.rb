class CreateAuditEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_entries do |t|
      t.references :run, null: false, foreign_key: true
      t.string :action, null: false
      t.string :subject, null: false

      t.timestamps
    end
  end
end
