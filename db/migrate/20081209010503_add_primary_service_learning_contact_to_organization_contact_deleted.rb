class AddPrimaryServiceLearningContactToOrganizationContactDeleted < ActiveRecord::Migration
  def self.up
    OrganizationContact::Deleted.update_columns
  end

  def self.down
    OrganizationContact::Deleted.update_columns
  end
end
