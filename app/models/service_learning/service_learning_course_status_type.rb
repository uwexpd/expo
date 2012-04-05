# Tracks the possible status types for ServiceLearningCourseStatus.
class ServiceLearningCourseStatusType < ActiveRecord::Base
  stampable
  has_many :service_learning_course_statuses
  
  validates_presence_of :title
  
end
