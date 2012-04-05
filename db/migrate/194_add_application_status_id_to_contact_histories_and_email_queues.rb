class AddApplicationStatusIdToContactHistoriesAndEmailQueues < ActiveRecord::Migration
  def self.up
    add_column :email_queues, :application_status_id, :integer
    add_column :contact_histories, :application_status_id, :integer
  end

  def self.down
    remove_column :email_queues, :application_status_id
    remove_column :contact_histories, :application_status_id
  end
end
