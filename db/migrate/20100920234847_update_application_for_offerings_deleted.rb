class UpdateApplicationForOfferingsDeleted < ActiveRecord::Migration
  def self.up
    ApplicationAnswer::Deleted.update_columns
    ApplicationAward::Deleted.update_columns
    ApplicationFile::Deleted.update_columns
    ApplicationForOffering::Deleted.update_columns
    ApplicationMentor::Deleted.update_columns
    ApplicationStatus::Deleted.update_columns
    Organization::Deleted.update_columns
    OrganizationContact::Deleted.update_columns
    OrganizationQuarter::Deleted.update_columns
    ServiceLearningCourse::Deleted.update_columns
    ServiceLearningOrientation::Deleted.update_columns
    ServiceLearningPlacement::Deleted.update_columns
    ServiceLearningPositionTime::Deleted.update_columns
    ServiceLearningPosition::Deleted.update_columns
    
  end

  def self.down
    ApplicationAnswer::Deleted.update_columns
    ApplicationAward::Deleted.update_columns
    ApplicationFile::Deleted.update_columns
    ApplicationForOffering::Deleted.update_columns
    ApplicationMentor::Deleted.update_columns
    ApplicationStatus::Deleted.update_columns
    Organization::Deleted.update_columns
    OrganizationContact::Deleted.update_columns
    OrganizationQuarter::Deleted.update_columns
    ServiceLearningCourse::Deleted.update_columns
    ServiceLearningOrientation::Deleted.update_columns
    ServiceLearningPlacement::Deleted.update_columns
    ServiceLearningPositionTime::Deleted.update_columns
    ServiceLearningPosition::Deleted.update_columns
    
  end
end
