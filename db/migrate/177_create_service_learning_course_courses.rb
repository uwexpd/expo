class CreateServiceLearningCourseCourses < ActiveRecord::Migration
  def self.up
    create_table :service_learning_course_courses do |t|
      t.integer :service_learning_course_id
      t.integer :ts_year
      t.integer :ts_quarter
      t.integer :course_branch
      t.integer :course_no
      t.string :dept_abbrev
      t.string :section_id

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :service_learning_course_courses
  end
end
