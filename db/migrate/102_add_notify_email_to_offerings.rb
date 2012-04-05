class AddNotifyEmailToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :notify_email, :string
  end

  def self.down
    remove_column :offerings, :notify_email
  end
end
