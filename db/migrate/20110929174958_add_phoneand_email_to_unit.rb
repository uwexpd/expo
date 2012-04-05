class AddPhoneandEmailToUnit < ActiveRecord::Migration
  def self.up
    add_column :units, :phone, :string
    add_column :units, :email, :string
  end

  def self.down
    remove_column :units, :email
    remove_column :units, :phone
  end
end
