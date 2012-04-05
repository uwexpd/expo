class CreatePipelineStudentTypes < ActiveRecord::Migration
  def self.up
    create_table :pipeline_student_types do |t|
      t.string :name
      t.text :description

    end
  end

  def self.down
    drop_table :pipeline_student_types
  end
end
