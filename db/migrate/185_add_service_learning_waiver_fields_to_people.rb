class AddServiceLearningWaiverFieldsToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :service_learning_risk_date, :datetime
    add_column :people, :service_learning_risk_signature, :string
    add_column :people, :service_learning_risk_position_id, :integer
  end

  def self.down
    remove_column :people, :service_learning_risk_position_id
    remove_column :people, :service_learning_risk_signature
    remove_column :people, :service_learning_risk_date
  end
end
