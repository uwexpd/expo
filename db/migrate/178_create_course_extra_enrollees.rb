class CreateCourseExtraEnrollees < ActiveRecord::Migration
  def self.up
    create_table :course_extra_enrollees do |t|
      t.integer :ts_year
      t.integer :ts_quarter
      t.integer :course_branch
      t.integer :course_no
      t.string :dept_abbrev
      t.string :section_id
      t.integer :person_id

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :course_extra_enrollees
  end
end
