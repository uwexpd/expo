class AddNoteToOrganizationContact < ActiveRecord::Migration
  def self.up
    add_column :organization_contacts, :note, :text
  end

  def self.down
    remove_column :organization_contacts, :note
  end
end
