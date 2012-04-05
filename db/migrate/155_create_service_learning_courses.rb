class CreateServiceLearningCourses < ActiveRecord::Migration
  def self.up
    create_table :service_learning_courses do |t|
      t.string :title
      t.string :quarter_id
      t.string :syllabus
      t.string :syllabus_url
      t.text :overview
      t.text :role_of_service_learning
      t.text :assignments
      t.datetime :presentation_time
      t.integer :presentation_length
      t.boolean :finalized
      t.datetime :registration_open_time

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :service_learning_courses
  end
end
