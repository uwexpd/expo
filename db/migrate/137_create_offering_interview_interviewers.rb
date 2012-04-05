class CreateOfferingInterviewInterviewers < ActiveRecord::Migration
  def self.up
    create_table :offering_interview_interviewers do |t|
      t.integer :offering_interview_id
      t.integer :offering_interviewer_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_interview_interviewers
  end
end
