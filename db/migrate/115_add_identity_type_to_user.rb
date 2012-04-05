class AddIdentityTypeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :identity_type, :string
  end

  def self.down
    remove_column :users, :identity_type
  end
end
