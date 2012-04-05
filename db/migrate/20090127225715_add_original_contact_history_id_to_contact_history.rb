class AddOriginalContactHistoryIdToContactHistory < ActiveRecord::Migration
  def self.up
    add_column :contact_histories, :original_contact_history_id, :integer
    add_column :email_queues, :original_contact_history_id, :integer
  end

  def self.down
    remove_column :email_queues, :original_contact_history_id
    remove_column :contact_histories, :original_contact_history_id
  end
end
