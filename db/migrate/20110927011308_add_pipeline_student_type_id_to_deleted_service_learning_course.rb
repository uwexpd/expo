class AddPipelineStudentTypeIdToDeletedServiceLearningCourse < ActiveRecord::Migration
  def self.up
    add_column :deleted_service_learning_courses, :pipeline_student_type_id, :integer
  end

  def self.down
    remove_column :deleted_service_learning_courses, :pipeline_student_type_id
  end
end
