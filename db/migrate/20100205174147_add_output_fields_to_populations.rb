class AddOutputFieldsToPopulations < ActiveRecord::Migration
  def self.up
    add_column :populations, :output_fields, :text
  end

  def self.down
    remove_column :populations, :output_fields
  end
end
