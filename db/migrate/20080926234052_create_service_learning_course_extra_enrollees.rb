class CreateServiceLearningCourseExtraEnrollees < ActiveRecord::Migration
  def self.up
    create_table :service_learning_course_extra_enrollees do |t|
      t.integer :service_learning_course_id
      t.integer :person_id
      t.integer :creator_id
      t.integer :updater_id

      t.timestamps
    end
  end

  def self.down
    drop_table :service_learning_course_extra_enrollees
  end
end
