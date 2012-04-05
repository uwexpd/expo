class AddServiceLearningContactToOrganizationContact < ActiveRecord::Migration
  def self.up
    add_column :organizations, :primary_service_learning_contact_id, :integer
  end

  def self.down
    remove_column :organizations, :primary_service_learning_contact_id
  end
end
