class AddTimestampsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :created_at, :timestamp
    add_column :people, :updated_at, :timestamp
  end

  def self.down
    remove_column :people, :updated_at
    remove_column :people, :created_at
  end
end
