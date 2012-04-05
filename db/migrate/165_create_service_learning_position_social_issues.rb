class CreateServiceLearningPositionSocialIssues < ActiveRecord::Migration
  def self.up
    create_table :service_learning_positions_social_issue_types do |t|
      t.integer :service_learning_position_id
      t.integer :social_issue_type_id

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :service_learning_positions_social_issue_types
  end
end
