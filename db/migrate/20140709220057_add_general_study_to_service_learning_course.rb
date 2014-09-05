class AddGeneralStudyToServiceLearningCourse < ActiveRecord::Migration
  def self.up
    add_column :service_learning_courses, :general_study, :boolean
  end

  def self.down
    remove_column :service_learning_courses, :general_study
  end
end
