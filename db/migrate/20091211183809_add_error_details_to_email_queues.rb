class AddErrorDetailsToEmailQueues < ActiveRecord::Migration
  def self.up
    add_column :email_queues, :error_details, :text
  end

  def self.down
    remove_column :email_queues, :error_details
  end
end
