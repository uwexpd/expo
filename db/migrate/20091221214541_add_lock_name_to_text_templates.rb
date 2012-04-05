class AddLockNameToTextTemplates < ActiveRecord::Migration
  def self.up
    add_column :text_templates, :lock_name, :boolean
  end

  def self.down
    remove_column :text_templates, :lock_name
  end
end
