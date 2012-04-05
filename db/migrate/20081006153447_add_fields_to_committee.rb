class AddFieldsToCommittee < ActiveRecord::Migration
  def self.up
    add_column :committees, :intro_text, :text
  end

  def self.down
    remove_column :committees, :column_name
  end
end
