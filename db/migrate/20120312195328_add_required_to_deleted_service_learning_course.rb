class AddRequiredToDeletedServiceLearningCourse < ActiveRecord::Migration
  def self.up
    add_column :deleted_service_learning_courses, :required, :boolean
  end

  def self.down
    remove_column :deleted_service_learning_courses, :required
  end
end
