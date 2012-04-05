class AddFinalTextToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :final_text, :text
  end

  def self.down
    remove_column :offerings, :final_text
  end
end
