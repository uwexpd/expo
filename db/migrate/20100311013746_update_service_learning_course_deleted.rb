class UpdateServiceLearningCourseDeleted < ActiveRecord::Migration
  def self.up
    ServiceLearningCourse::Deleted.update_columns
  end

  def self.down
    ServiceLearningCourse::Deleted.update_columns
  end
end
