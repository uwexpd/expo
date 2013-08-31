class CreateServiceLearningSelfPlacements < ActiveRecord::Migration
  def self.up
    create_table :service_learning_self_placements do |t|
      t.integer :person_id
      t.integer :service_learning_placement_id
      t.integer :service_learning_position_id
      t.integer :service_learning_course_id
      t.integer :quarter_id
      t.string :organization_id
      t.string :organization_mailing_line_1
      t.string :organization_mailing_line_2
      t.string :organization_mailing_city
      t.string :organization_mailing_state
      t.string :organization_mailing_zip
      t.string :organization_website_url
      t.string :organization_contact_person
      t.string :organization_contact_phone
      t.string :organization_contact_title
      t.string :organization_contact_email
      t.text :organization_mission_statement
      t.text :hope_to_learn
      t.boolean :submitted
      t.boolean :faculty_approved
      t.text :faculty_feedback
      t.boolean :admin_approved
      
      t.timestamps
    end
  end

  def self.down
    drop_table :service_learning_self_placements
  end
end
