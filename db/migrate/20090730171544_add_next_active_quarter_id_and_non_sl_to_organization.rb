class AddNextActiveQuarterIdAndNonSlToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :next_active_quarter_id, :integer
    add_column :organizations, :archive, :boolean
    add_column :organizations, :does_service_learning, :boolean
    Organization::Deleted.update_columns
    OrganizationQuarter::Deleted.update_columns
    ServiceLearningPosition::Deleted.update_columns
    ServiceLearningPositionTime::Deleted.update_columns
  end

  def self.down
    remove_column :organizations, :service_learning
    remove_column :organizations, :archive
    remove_column :organizations, :next_active_quarter_id
    ServiceLearningPositionTime::Deleted.update_columns
    ServiceLearningPosition::Deleted.update_columns
    OrganizationQuarter::Deleted.update_columns
    Organization::Deleted.update_columns
  end
end
