class CreatePotentialCourseOrganizationMatchForQuarters < ActiveRecord::Migration
  def self.up
    create_table :potential_course_organization_match_for_quarters do |t|
      t.integer :organization_quarter_id
      t.integer :service_learning_course_id

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :potential_course_organization_match_for_quarters
  end
end
