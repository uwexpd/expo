class AddActsAsSoftDeletable < ActiveRecord::Migration
  def self.up
    ServiceLearningPositionTime::Deleted.create_table
    ServiceLearningCourse::Deleted.create_table
    ServiceLearningOrientation::Deleted.create_table
    ServiceLearningPlacement::Deleted.create_table
    Organization::Deleted.create_table
    OrganizationQuarter::Deleted.create_table
    OrganizationContact::Deleted.create_table
    ApplicationForOffering::Deleted.create_table
    ApplicationAnswer::Deleted.create_table
    ApplicationAward::Deleted.create_table
    ApplicationFile::Deleted.create_table
    ApplicationMentor::Deleted.create_table
    ApplicationStatus::Deleted.create_table
  end

  def self.down
    ServiceLearningPositionTime::Deleted.drop_table
    ServiceLearningCourse::Deleted.drop_table
    ServiceLearningOrientation::Deleted.drop_table
    ServiceLearningPlacement::Deleted.drop_table
    Organization::Deleted.drop_table
    OrganizationQuarter::Deleted.drop_table
    OrganizationContact::Deleted.drop_table
    ApplicationForOffering::Deleted.drop_table
    ApplicationAnswer::Deleted.drop_table
    ApplicationAward::Deleted.drop_table
    ApplicationFile::Deleted.drop_table
    ApplicationMentor::Deleted.drop_table
    ApplicationStatus::Deleted.drop_table  
  end
end
