class CreatePipelineStudentInfo < ActiveRecord::Migration
  def self.up
    create_table :pipeline_student_info do |t|
      t.integer :person_id
      t.text :how_did_you_hear
      t.text :languages
      t.text :fulfill_mit
    end
  end

  def self.down
    drop_table :pipeline_student_info
  end
end
