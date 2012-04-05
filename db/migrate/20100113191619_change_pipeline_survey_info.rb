class ChangePipelineSurveyInfo < ActiveRecord::Migration
  def self.up
    add_column :pipeline_student_info, :pursue_els, :string
    add_column :pipeline_student_info, :teaching_career, :string
    add_column :pipeline_student_info, :apply_masters, :boolean
    remove_column :pipeline_student_info, :languages
  end

  def self.down
    remove_column :pipeline_student_info, :pursue_els
    remove_column :pipeline_student_info, :teaching_career
    remove_column :pipeline_student_info, :apply_masters
    add_column :pipeline_student_info, :languages, :string
  end
end
