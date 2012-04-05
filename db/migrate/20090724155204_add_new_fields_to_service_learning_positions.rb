class AddNewFieldsToServiceLearningPositions < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :context_description, :text
    add_column :service_learning_positions, :impact_description, :text
    add_column :service_learning_positions, :skills_requirement, :text
    add_column :service_learning_positions, :ideal_number_of_slots, :integer
    add_column :service_learning_positions, :background_check_required, :boolean
    add_column :service_learning_positions, :tb_test_required, :boolean
    add_column :service_learning_positions, :paperwork_requirement, :text
    add_column :service_learning_positions, :time_commitment_requirement, :string
    add_column :service_learning_orientations, :different_orientation_contact, :boolean
    add_column :service_learning_orientations, :organization_contact_id, :integer
    add_column :service_learning_orientations, :different_orientation_location, :boolean
    add_column :service_learning_positions, :in_progress, :boolean
    ServiceLearningPosition::Deleted.update_columns
    ServiceLearningOrientation::Deleted.update_columns
  end

  def self.down
    remove_column :service_learning_positions, :in_progress
    remove_column :service_learning_orientations, :different_orientation_location
    remove_column :service_learning_orientations, :organization_contact_id
    remove_column :service_learning_orientations, :different_orientation_contact
    remove_column :service_learning_positions, :time_commitment_requirement
    remove_column :service_learning_positions, :paperwork_requirement
    remove_column :service_learning_positions, :tb_test_required
    remove_column :service_learning_positions, :background_check_required
    remove_column :service_learning_positions, :ideal_number_of_slots
    remove_column :service_learning_positions, :skills_requirement
    remove_column :service_learning_positions, :impact_description
    remove_column :service_learning_positions, :context_description
    ServiceLearningPosition::Deleted.update_columns
    ServiceLearningOrientation::Deleted.update_columns
  end
end
