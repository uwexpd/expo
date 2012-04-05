class AddCommandAfterDeliveryToEmailQueue < ActiveRecord::Migration
  def self.up
    add_column :email_queues, :command_after_delivery, :text
  end

  def self.down
    remove_column :email_queues, :command_after_delivery
  end
end
