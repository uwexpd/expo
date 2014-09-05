class AddGeneralStudyToServiceLearningSelfPlacement < ActiveRecord::Migration
  def self.up    
    add_column :service_learning_self_placements, :faculty_person_id, :string
    add_column :service_learning_self_placements, :faculty_firstname, :string
    add_column :service_learning_self_placements, :faculty_lastname,  :string
    add_column :service_learning_self_placements, :faculty_email, :string
    add_column :service_learning_self_placements, :faculty_dept,  :string
    add_column :service_learning_self_placements, :faculty_phone, :string
    add_column :service_learning_self_placements, :general_study, :boolean
    add_column :service_learning_self_placements, :supervisor_approved, :boolean
    add_column :service_learning_self_placements, :supervisor_feedback, :text
    add_column :service_learning_self_placements, :general_study_risk_date, :datetime
    add_column :service_learning_self_placements, :general_study_risk_signature, :string
    add_column :service_learning_self_placements, :register_person_id, :integer
    add_column :service_learning_self_placements, :registered_at, :datetime
  end

  def self.down
    remove_column :service_learning_self_placements, :faculty_person_id
    remove_column :service_learning_self_placements, :faculty_firstname
    remove_column :service_learning_self_placements, :faculty_lastname
    remove_column :service_learning_self_placements, :faculty_email
    remove_column :service_learning_self_placements, :faculty_dept
    remove_column :service_learning_self_placements, :faculty_phone             
    remove_column :service_learning_self_placements, :general_study
    remove_column :service_learning_self_placements, :supervisor_approved
    remove_column :service_learning_self_placements, :supervisor_feedback    
    remove_column :service_learning_self_placements, :general_study_risk_date
    remove_column :service_learning_self_placements, :general_study_risk_signature    
    remove_column :service_learning_self_placements, :register_person_id
    remove_column :service_learning_self_placements, :registered_at
  end
end
