class CreateApplicationMentors < ActiveRecord::Migration
  def self.up
    create_table :application_mentors do |t|
      t.integer :application_for_offering_id
      t.integer :person_id
      t.boolean :primary

      t.timestamps
    end
  end

  def self.down
    drop_table :application_mentors
  end
end
