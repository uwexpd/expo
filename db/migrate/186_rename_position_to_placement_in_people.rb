class RenamePositionToPlacementInPeople < ActiveRecord::Migration
  def self.up
    rename_column :people, :service_learning_risk_position_id, :service_learning_risk_placement_id
  end

  def self.down
    rename_column :people, :service_learning_risk_placement_id, :service_learning_risk_position_id
  end
end
