class AddEndedAtToRuns < ActiveRecord::Migration[8.1]
  def change
    add_column :runs, :ended_at, :datetime
  end
end
