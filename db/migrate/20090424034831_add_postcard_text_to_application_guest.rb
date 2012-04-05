class AddPostcardTextToApplicationGuest < ActiveRecord::Migration
  def self.up
    add_column :application_guests, :postcard_text, :text
  end

  def self.down
    remove_column :application_guests, :postcard_text
  end
end
