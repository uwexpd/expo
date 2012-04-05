class CreateServiceLearningCourseStatusTypes < ActiveRecord::Migration
  def self.up
    create_table :service_learning_course_status_types do |t|
      t.string :title

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :service_learning_course_status_types
  end
end
