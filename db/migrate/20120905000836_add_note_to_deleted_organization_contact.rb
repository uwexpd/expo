class AddNoteToDeletedOrganizationContact < ActiveRecord::Migration
  def self.up
    add_column :deleted_organization_contacts, :note, :text
  end

  def self.down
    remove_column :deleted_organization_contacts, :note
  end
end
