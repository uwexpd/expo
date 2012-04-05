class AddDoesPipelineToOrgs < ActiveRecord::Migration
  def self.up
    add_column :organizations, :does_pipeline, :boolean
  end

  def self.down
    remove_column :organizations, :does_pipeline
  end
end
