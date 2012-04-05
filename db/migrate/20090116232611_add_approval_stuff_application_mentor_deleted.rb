class AddApprovalStuffApplicationMentorDeleted < ActiveRecord::Migration
  def self.up
    ApplicationMentor::Deleted.update_columns
  end

  def self.down
    ApplicationMentor::Deleted.update_columns
  end
end
