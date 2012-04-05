class AddPipelineStudentTypeIdToServiceLearningCourse < ActiveRecord::Migration
  def self.up
    add_column :service_learning_courses, :pipeline_student_type_id, :integer
  end

  def self.down
    remove_column :service_learning_courses, :pipeline_student_type_id
  end
end
