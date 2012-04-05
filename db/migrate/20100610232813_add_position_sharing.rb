class AddPositionSharing < ActiveRecord::Migration
  def self.up
    create_table :service_learning_position_shares do |t|
      t.integer :unit_id
      t.integer :service_learning_position_id
      t.boolean :allow_edit

      t.timestamps
    end
    
    add_column :service_learning_courses, :no_filters, :boolean
    add_column :service_learning_placements, :unit_id, :integer
    
    ServiceLearningCourse::Deleted.update_columns
    ServiceLearningPlacement::Deleted.update_columns
  end

  def self.down
    drop_table :service_learning_position_shares
    
    remove_column :service_learning_courses, :no_filters
    remove_column :service_learning_placements, :unit_id
    
    ServiceLearningCourse::Deleted.update_columns
    ServiceLearningPlacement::Deleted.update_columns
  end
end
