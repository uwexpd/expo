class AddSubmittedAtToEvaluation < ActiveRecord::Migration
  def self.up
    add_column :evaluations, :submitted_at, :datetime
  end

  def self.down
    remove_column :evaluations, :submitted_at
  end
end
