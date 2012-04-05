class AddSessionIdToLoginHistory < ActiveRecord::Migration
  def self.up
    add_column :login_histories, :session_id, :string
  end

  def self.down
    remove_column :login_histories, :session_id
  end
end
