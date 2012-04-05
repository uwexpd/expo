class MakePipelinePositionTables < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :type, :string
    
    create_table :pipeline_positions_subjects do |t|
      t.string  :name
      t.text  :description
    end
    create_table :pipeline_positions_subjects_links do |t|
      t.integer :pipeline_position_id
      t.integer :pipeline_position_subject_id
    end
    
    create_table :pipeline_positions_tutoring_types do |t|
      t.string  :name
      t.text  :description
    end
    create_table :pipeline_positions_tutoring_types_links do |t|
      t.integer :pipeline_position_id
      t.integer :pipeline_position_tutoring_type_id
    end
    
    create_table :pipeline_positions_grade_levels do |t|
      t.string  :name
      t.text  :description
    end
    create_table :pipeline_positions_grade_levels_links do |t|
      t.integer :pipeline_position_id
      t.integer :pipeline_position_grade_level_id
    end
  end

  def self.down
    remove_column :service_learning_positions, :type
    
    drop_table :pipeline_positions_subjects_links
    drop_table :pipeline_positions_tutoring_types_links
    drop_table :pipeline_positions_grade_levels_links
    drop_table :pipeline_positions_subjects
    drop_table :pipeline_positions_tutoring_types
    drop_table :pipeline_positions_grade_levels
  end
end