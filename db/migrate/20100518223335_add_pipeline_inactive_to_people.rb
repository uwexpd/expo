class AddPipelineInactiveToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :pipeline_inactive, :boolean
  end

  def self.down
    remove_column :people, :pipeline_inactive
  end
end
