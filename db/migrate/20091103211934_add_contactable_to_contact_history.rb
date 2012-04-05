class AddContactableToContactHistory < ActiveRecord::Migration
  def self.up
    add_column :contact_histories, :contactable_type, :string
    add_column :contact_histories, :contactable_id, :integer
    add_column :email_queues, :contactable_type, :string
    add_column :email_queues, :contactable_id, :integer
    add_index :contact_histories, :person_id
    add_index :contact_histories, :contactable_type
    add_index :contact_histories, :contactable_id
  end

  def self.down
    remove_index :contact_histories, :contactable_id
    remove_index :contact_histories, :contactable_type
    remove_index :contact_histories, :person_id
    remove_column :email_queues, :contactable_id
    remove_column :email_queues, :contactable_type
    remove_column :contact_histories, :contactable_id
    remove_column :contact_histories, :contactable_type
  end
end
