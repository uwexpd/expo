class AddScoresToInterviewers < ActiveRecord::Migration
  def self.up
    add_column :offering_interviewers, :committee_member_id, :integer
    add_column :offering_interview_interviewers, :finalized, :boolean
    add_column :offering_interview_interviewers, :committee_score, :boolean
    create_table :offering_interview_interviewer_scores, :force => true do |t|
      t.integer :offering_interview_interviewer_id
      t.integer :offering_review_criterion_id
      t.integer :score
      t.text :comments
      t.integer :creator_id
      t.integer :updater_id
      t.integer :deleter_id
      t.timestamps
    end
    add_column :offerings, :uses_scored_interviews, :boolean
    add_column :offerings, :interviewer_help_text, :text
  end

  def self.down
    remove_column :offerings, :interviewer_help_text
    remove_column :offering_interview_interviewers, :committee_score
    remove_column :offering_interview_interviewers, :finalized
    remove_column :offerings, :uses_scored_interviews
    drop_table :offering_interview_interviewer_scores
    remove_column :offering_interviewers, :committee_member_id
  end
end
