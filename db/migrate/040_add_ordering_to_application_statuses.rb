class AddOrderingToApplicationStatuses < ActiveRecord::Migration
  def self.up
    add_column :application_statuses, :ordering, :integer
  end

  def self.down
    remove_column :application_statuses, :ordering
  end
end
