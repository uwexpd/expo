class AddIpToLoginHistory < ActiveRecord::Migration
  def self.up
    add_column :login_histories, :ip, :string
  end

  def self.down
    remove_column :login_histories, :ip
  end
end
