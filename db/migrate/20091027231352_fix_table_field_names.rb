class FixTableFieldNames < ActiveRecord::Migration
  def self.up
    rename_column :pipeline_positions_subjects_links, :pipeline_position_subject_id, :pipeline_positions_subject_id 
    rename_column :pipeline_positions_tutoring_types_links, :pipeline_position_tutoring_type_id, :pipeline_positions_tutoring_type_id 
    rename_column :pipeline_positions_grade_levels_links, :pipeline_position_grade_level_id, :pipeline_positions_grade_level_id 
  end

  def self.down
    rename_column :pipeline_positions_subjects_links, :pipeline_positions_subject_id, :pipeline_position_subject_id 
    rename_column :pipeline_positions_tutoring_types_links, :pipeline_positions_tutoring_type_id, :pipeline_position_tutoring_type_id 
    rename_column :pipeline_positions_grade_levels_links, :pipeline_positions_grade_level_id, :pipeline_position_grade_level_id 
  end
end
