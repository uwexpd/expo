class AddMentorModeToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :mentor_mode, :string
  end

  def self.down
    remove_column :offerings, :mentor_mode
  end
end
