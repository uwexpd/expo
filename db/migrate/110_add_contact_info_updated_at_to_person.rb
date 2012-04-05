class AddContactInfoUpdatedAtToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :contact_info_updated_at, :datetime
  end

  def self.down
    remove_column :people, :contact_info_updated_at
  end
end
