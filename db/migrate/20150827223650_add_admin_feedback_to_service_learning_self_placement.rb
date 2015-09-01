class AddAdminFeedbackToServiceLearningSelfPlacement < ActiveRecord::Migration
  def self.up
    add_column :service_learning_self_placements, :admin_feedback, :text
  end

  def self.down
    remove_column :service_learning_self_placements, :admin_feedback
  end
end
