class CreateUserEmailAddresses < ActiveRecord::Migration
  def self.up
    create_table :user_email_addresses do |t|
      t.integer :user_id
      t.string :name
      t.string :email
      t.timestamps
    end
    add_column :users, :default_email_address_id, :integer
  end

  def self.down
    remove_column :users, :default_email_address_id
    drop_table :user_email_addresses
  end
end
