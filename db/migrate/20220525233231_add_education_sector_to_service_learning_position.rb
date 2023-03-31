class AddEducationSectorToServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :education_sector, :boolean
  end

  def self.down
    remove_column :service_learning_positions, :education_sector
  end
end
