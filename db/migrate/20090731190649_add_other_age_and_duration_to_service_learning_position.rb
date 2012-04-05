class AddOtherAgeAndDurationToServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :other_age_requirement, :text
    add_column :service_learning_positions, :other_duration_requirement, :text
    ServiceLearningPosition::Deleted.update_columns
  end

  def self.down
    remove_column :service_learning_positions, :other_duration_requirement
    remove_column :service_learning_positions, :other_age_requirement
    ServiceLearningPosition::Deleted.update_columns
  end
end
