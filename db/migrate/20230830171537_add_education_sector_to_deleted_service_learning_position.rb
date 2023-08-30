class AddEducationSectorToDeletedServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :deleted_service_learning_positions, :education_sector, :integer
  end

  def self.down
    remove_column :deleted_service_learning_positions, :education_sector
  end
end
