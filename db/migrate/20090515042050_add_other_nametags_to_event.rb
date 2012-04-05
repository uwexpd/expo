class AddOtherNametagsToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :other_nametags, :text
  end

  def self.down
    remove_column :events, :other_nametags
  end
end
