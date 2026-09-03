class CreateAgentMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_messages do |t|
      t.references :run, null: false, foreign_key: true
      t.references :card, foreign_key: true
      t.string :from_role, null: false
      t.string :to_role, null: false
      t.text :body, null: false

      t.timestamps
    end
  end
end
