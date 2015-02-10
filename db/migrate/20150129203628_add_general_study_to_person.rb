class AddGeneralStudyToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :general_study_risk_date, :datetime
    add_column :people, :general_study_risk_signature, :string
    add_column :people, :general_study_risk_placement_id, :integer
  end

  def self.down
    remove_column :people, :general_study_risk_placement_id
    remove_column :people, :general_study_risk_signature
    remove_column :people, :general_study_risk_date
  end
end
