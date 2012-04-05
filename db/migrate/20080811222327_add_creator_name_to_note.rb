class AddCreatorNameToNote < ActiveRecord::Migration
  def self.up
    add_column :notes, :creator_name, :string
  end

  def self.down
    remove_column :notes, :creator_name
  end
end
