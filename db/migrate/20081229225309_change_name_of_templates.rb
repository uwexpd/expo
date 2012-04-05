class ChangeNameOfTemplates < ActiveRecord::Migration
  def self.up
    rename_table :templates, :text_templates
  end

  def self.down
    rename_table :text_templates, :templates
  end
end
