class AddAlternateStylesheetToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :alternate_stylesheet, :string
  end

  def self.down
    remove_column :offerings, :alternate_stylesheet
  end
end
