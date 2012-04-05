class ChangeContactTypeToContactTypeId < ActiveRecord::Migration
  def self.up
    remove_column :appointments, :contact_type
    add_column :appointments, :contact_type_id, :integer
  end

  def self.down
    add_column :appointments, :contact_type, :string
    remove_column :appointments, :contact_type_id
  end
end
