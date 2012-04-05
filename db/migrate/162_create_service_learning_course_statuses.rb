class CreateServiceLearningCourseStatuses < ActiveRecord::Migration
  def self.up
    create_table :service_learning_course_statuses do |t|
      t.integer :service_learning_course_id
      t.integer :service_learning_course_status_type_id

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :service_learning_course_statuses
  end
end
