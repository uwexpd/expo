class AddPipelineContactBoolToOrgContact < ActiveRecord::Migration
  def self.up
    add_column :organization_contacts, :pipeline_contact, :boolean
  end

  def self.down
    remove_column :organization_contacts, :pipeline_contact
  end
end
