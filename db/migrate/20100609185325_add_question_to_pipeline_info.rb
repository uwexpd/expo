class AddQuestionToPipelineInfo < ActiveRecord::Migration
  def self.up
    add_column :pipeline_student_info, :current_els_minor, :boolean
  end

  def self.down
    remove_column :pipeline_student_info, :current_els_minor
  end
end
