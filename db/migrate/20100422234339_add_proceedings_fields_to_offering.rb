class AddProceedingsFieldsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :uses_proceedings, :boolean
    add_column :offerings, :uses_lookup, :boolean
    add_column :offerings, :proceedings_welcome_text, :text
  end

  def self.down
    remove_column :offerings, :proceedings_welcome_text
    remove_column :offerings, :uses_lookup
    remove_column :offerings, :uses_proceedings
  end
end
