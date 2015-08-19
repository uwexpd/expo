class AddRequirementToDeletedServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :deleted_service_learning_positions, :flu_vaccination_required, :boolean
    add_column :deleted_service_learning_positions, :food_permit_required, :boolean
    add_column :deleted_service_learning_positions, :other_health_required, :boolean
    add_column :deleted_service_learning_positions, :other_health_requirement, :string
    add_column :deleted_service_learning_positions, :legal_name_required, :boolean
    add_column :deleted_service_learning_positions, :birthdate_required, :boolean
    add_column :deleted_service_learning_positions, :ssn_required, :boolean
    add_column :deleted_service_learning_positions, :fingerprint_required, :boolean
    add_column :deleted_service_learning_positions, :other_background_check_required, :boolean
    add_column :deleted_service_learning_positions, :other_background_check_requirement, :string
    add_column :deleted_service_learning_positions, :non_intl_student_required, :boolean
  end

  def self.down
    remove_column :deleted_service_learning_positions, :non_intl_student_required
    remove_column :deleted_service_learning_positions, :other_background_check_requirement
    remove_column :deleted_service_learning_positions, :other_background_check_required
    remove_column :deleted_service_learning_positions, :fingerprint_required
    remove_column :deleted_service_learning_positions, :ssn_required
    remove_column :deleted_service_learning_positions, :birthdate_required
    remove_column :deleted_service_learning_positions, :legal_name_required
    remove_column :deleted_service_learning_positions, :other_health_requirement
    remove_column :deleted_service_learning_positions, :other_health_required
    remove_column :deleted_service_learning_positions, :food_permit_required
    remove_column :deleted_service_learning_positions, :flu_vaccination_required
  end
end
