class CreateServiceLearningCourseInstructors < ActiveRecord::Migration
  def self.up
    create_table :service_learning_course_instructors do |t|
      t.integer :service_learning_course_id
      t.integer :person_id
      t.boolean :ta

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :service_learning_course_instructors
  end
end
