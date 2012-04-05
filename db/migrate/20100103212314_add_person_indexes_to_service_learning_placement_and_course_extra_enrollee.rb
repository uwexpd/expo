class AddPersonIndexesToServiceLearningPlacementAndCourseExtraEnrollee < ActiveRecord::Migration
  def self.up
    add_index :service_learning_placements, :person_id
    add_index :service_learning_placements, :service_learning_position_id, :name => "index_placements_on_position_id"
    add_index :service_learning_placements, :service_learning_course_id, :name => "index_placements_on_course_id"
    add_index :course_extra_enrollees, :person_id
    add_index :service_learning_course_extra_enrollees, :person_id, :name => "index_enrollees_on_person_id"
    add_index :course_extra_enrollees, [:ts_year, :ts_quarter, :course_branch, :course_no, :dept_abbrev, :section_id], :name => "course_id_index"
  end

  def self.down
    remove_index :course_extra_enrollees, :name => :course_id_index
    remove_index :service_learning_course_extra_enrollees, :person_id, :name => "index_enrollees_on_person_id"
    remove_index :course_extra_enrollees, :person_id
    remove_index :service_learning_placements, :service_learning_course_id, :name => "index_placements_on_course_id"
    remove_index :service_learning_placements, :service_learning_position_id, :name => "index_placements_on_position_id"
    remove_index :service_learning_placements, :person_id
  end
end
