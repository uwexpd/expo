class AddIndexToContactHistory < ActiveRecord::Migration
  def self.up
    add_index :contact_histories, :creator_id
  end

  def self.down
    remove_index :contact_histories, :creator_id
  end
end
