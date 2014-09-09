class AddGeneralStudyToDeletedServiceLearningCourses < ActiveRecord::Migration
  def self.up
    add_column :deleted_service_learning_courses, :general_study, :boolean
  end

  def self.down
    remove_column :deleted_service_learning_courses, :general_study
  end
end
