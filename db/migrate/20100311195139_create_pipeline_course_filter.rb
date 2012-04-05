class CreatePipelineCourseFilter < ActiveRecord::Migration
  def self.up
    create_table :pipeline_course_filters do |t|
      t.integer :service_learning_course_id
      t.text :filters
    end
  end

  def self.down
    drop_table :pipeline_course_filters 
  end
end
