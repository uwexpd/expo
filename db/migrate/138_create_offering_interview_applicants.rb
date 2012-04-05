class CreateOfferingInterviewApplicants < ActiveRecord::Migration
  def self.up
    create_table :offering_interview_applicants do |t|
      t.integer :offering_interview_id
      t.integer :application_for_offering_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_interview_applicants
  end
end
