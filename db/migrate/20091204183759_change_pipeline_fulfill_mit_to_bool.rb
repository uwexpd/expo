class ChangePipelineFulfillMitToBool < ActiveRecord::Migration
  def self.up
    change_column :pipeline_student_info, :fulfill_mit, :boolean
  end

  def self.down
    change_column :pipeline_student_info, :fulfill_mit, :text 
  end
end
