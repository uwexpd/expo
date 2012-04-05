class AddServiceLearningRiskPaperDateToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :service_learning_risk_paper_date, :datetime
  end

  def self.down
    remove_column :people, :service_learning_risk_paper_date
  end
end
