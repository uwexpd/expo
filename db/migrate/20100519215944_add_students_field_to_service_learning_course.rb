class AddStudentsFieldToServiceLearningCourse < ActiveRecord::Migration
  def self.up
    add_column :service_learning_courses, :students, :text
    
    ServiceLearningCourse::Deleted.update_columns
  end

  def self.down
    remove_column :service_learning_courses, :students
    
    ServiceLearningCourse::Deleted.update_columns
  end
end
