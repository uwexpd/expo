class AddRequiredToServiceLearningCourse < ActiveRecord::Migration
  def self.up
    add_column :service_learning_courses, :required, :boolean, :default => false
  end

  def self.down
    remove_column :service_learning_courses, :required
  end
end
