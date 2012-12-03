class AddTutoringSubmittedAtToServiceLearningPlacement < ActiveRecord::Migration
  def self.up
    add_column :service_learning_placements, :tutoring_submitted_at, :datetime
    add_column :deleted_service_learning_placements, :tutoring_submitted_at, :datetime
  end

  def self.down
    remove_column :service_learning_placements, :tutoring_submitted_at
    remove_column :deleted_service_learning_placements, :tutoring_submitted_at
  end
end
