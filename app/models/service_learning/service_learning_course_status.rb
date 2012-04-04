# A ServiceLearningCourse can go through many statuses in a given Quarter. The ServiceLearningCourse object has a method called +current_status+ that returns the most recent status of the OrganizationQuarter.
class ServiceLearningCourseStatus < ActiveRecord::Base
  stampable
  belongs_to :service_learning_course
  belongs_to :service_learning_course_status_type
  
  validates_presence_of :service_learning_course_id
  validates_presence_of :service_learning_course_status_type_id
  
end
