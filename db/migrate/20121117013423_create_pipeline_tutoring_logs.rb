class CreatePipelineTutoringLogs < ActiveRecord::Migration
  def self.up
    create_table :pipeline_tutoring_logs do |t|
      t.integer :service_learning_placement_id
      t.decimal :hours, :precision => 10, :scale => 2
      t.date :log_date

      t.timestamps
    end
  end

  def self.down
    drop_table :pipeline_tutoring_logs
  end
end
