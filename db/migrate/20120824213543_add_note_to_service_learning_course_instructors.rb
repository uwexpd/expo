class AddNoteToServiceLearningCourseInstructors < ActiveRecord::Migration
  def self.up
    add_column :service_learning_course_instructors, :note, :text
  end

  def self.down
    remove_column :service_learning_course_instructors, :note
  end
end
