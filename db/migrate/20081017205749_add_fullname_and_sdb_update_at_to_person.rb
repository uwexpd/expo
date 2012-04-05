class AddFullnameAndSdbUpdateAtToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :fullname, :string
    add_column :people, :sdb_update_at, :datetime
  end

  def self.down
    remove_column :people, :sdb_update_at
    remove_column :people, :fullname
  end
end
