class AddGeneralStudyToServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :general_study, :boolean
    add_column :service_learning_positions, :learning_goals, :text
    add_column :service_learning_positions, :academic_topics, :text
    add_column :service_learning_positions, :sources, :text
    add_column :service_learning_positions, :public_service, :boolean
    add_column :service_learning_positions, :total_hours, :integer
    add_column :service_learning_positions, :credit, :integer
    add_column :service_learning_positions, :volunteer, :integer
    add_column :service_learning_positions, :compensation, :decimal, :precision => 8, :scale => 2
    
    add_column :deleted_service_learning_positions, :general_study, :boolean
    add_column :deleted_service_learning_positions, :learning_goals, :text
    add_column :deleted_service_learning_positions, :academic_topics, :text
    add_column :deleted_service_learning_positions, :sources, :text
    add_column :deleted_service_learning_positions, :public_service, :boolean
    add_column :deleted_service_learning_positions, :total_hours, :integer
    add_column :deleted_service_learning_positions, :credit, :integer
    add_column :deleted_service_learning_positions, :volunteer, :integer
    add_column :deleted_service_learning_positions, :compensation, :decimal, :precision => 8, :scale => 2    
  end

  def self.down
    remove_column :service_learning_positions, :general_study
    remove_column :service_learning_positions, :learning_goals
    remove_column :service_learning_positions, :academic_topics
    remove_column :service_learning_positions, :sources
    remove_column :service_learning_positions, :public_service
    remove_column :service_learning_positions, :total_hours
    remove_column :service_learning_positions, :credit
    remove_column :service_learning_positions, :volunteer
    remove_column :service_learning_positions, :compensation    
    
    remove_column :deleted_service_learning_positions, :general_study
    remove_column :deleted_service_learning_positions, :learning_goals
    remove_column :deleted_service_learning_positions, :academic_topics
    remove_column :deleted_service_learning_positions, :sources
    remove_column :deleted_service_learning_positions, :public_service
    remove_column :deleted_service_learning_positions, :total_hours
    remove_column :deleted_service_learning_positions, :credit
    remove_column :deleted_service_learning_positions, :volunteer
    remove_column :deleted_service_learning_positions, :compensation        
  end
end
