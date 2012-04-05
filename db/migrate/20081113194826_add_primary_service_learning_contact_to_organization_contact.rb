class AddPrimaryServiceLearningContactToOrganizationContact < ActiveRecord::Migration
  def self.up
    add_column :organization_contacts, :primary_service_learning_contact, :boolean
  end

  def self.down
    remove_column :organization_contacts, :primary_service_learning_contact
  end
end
