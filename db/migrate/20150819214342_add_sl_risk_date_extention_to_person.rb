class AddSlRiskDateExtentionToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :service_learning_risk_date_extention, :boolean
  end

  def self.down
    remove_column :people, :service_learning_risk_date_extention
  end
end
