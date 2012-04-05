class AddObjectFieldsToPopulation < ActiveRecord::Migration
  def self.up
    add_column :populations, :object_ids, :text
    add_column :populations, :objects_generated_at, :datetime
    add_column :populations, :objects_count, :integer
  end

  def self.down
    remove_column :populations, :objects_count
    remove_column :populations, :objects_generated_at
    remove_column :populations, :object_ids
  end
end
