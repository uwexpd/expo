class AddPipelineOrientationAndBackgroundCheckToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :pipeline_orientation, :datetime
    add_column :people, :pipeline_background_check, :datetime
  end

  def self.down
    remove_column :people, :pipeline_orientation
    remove_column :people, :pipeline_background_check
  end
end
