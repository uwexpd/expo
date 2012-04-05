class AddPositionCounterCachesToOrganizationQuarter < ActiveRecord::Migration
  def self.up
    add_column :organization_quarters, :in_progress_positions_count, :integer
    add_column :organization_quarters, :pending_positions_count, :integer
    add_column :organization_quarters, :approved_positions_count, :integer
    
    OrganizationQuarter.all.each do |oq|
      oq.update_position_counts!
    end
    
    ApplicationAnswer::Deleted.update_columns
    ApplicationAward::Deleted.update_columns
    ApplicationFile::Deleted.update_columns
    ApplicationForOffering::Deleted.update_columns
    ApplicationMentor::Deleted.update_columns
    ApplicationStatus::Deleted.update_columns
    OrganizationContact::Deleted.update_columns
    OrganizationQuarter::Deleted.update_columns
    Organization::Deleted.update_columns
    ServiceLearningCourse::Deleted.update_columns
    ServiceLearningOrientation::Deleted.update_columns
    ServiceLearningPlacement::Deleted.update_columns
    ServiceLearningPositionTime::Deleted.update_columns
    ServiceLearningPosition::Deleted.update_columns
  end

  def self.down
    remove_column :organization_quarters, :approved_positions_count
    remove_column :organization_quarters, :pending_positions_count
    remove_column :organization_quarters, :in_progress_positions_count
    
    ApplicationAnswer::Deleted.update_columns
    ApplicationAward::Deleted.update_columns
    ApplicationFile::Deleted.update_columns
    ApplicationForOffering::Deleted.update_columns
    ApplicationMentor::Deleted.update_columns
    ApplicationStatus::Deleted.update_columns
    OrganizationContact::Deleted.update_columns
    OrganizationQuarter::Deleted.update_columns
    Organization::Deleted.update_columns
    ServiceLearningCourse::Deleted.update_columns
    ServiceLearningOrientation::Deleted.update_columns
    ServiceLearningPlacement::Deleted.update_columns
    ServiceLearningPositionTime::Deleted.update_columns
    ServiceLearningPosition::Deleted.update_columns
  end
end
