class ChangeTitleToAlternateTitleInServiceLearningCourses < ActiveRecord::Migration
  def self.up
    rename_column :service_learning_courses, :title, :alternate_title
  end

  def self.down
    rename_column :service_learning_courses, :alternate_title, :title
  end
end
