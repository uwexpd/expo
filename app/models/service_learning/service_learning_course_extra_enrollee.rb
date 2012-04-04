class ServiceLearningCourseExtraEnrollee < ActiveRecord::Base
  stampable
  belongs_to :service_learning_course
  belongs_to :person
  
  validates_presence_of :person
  validates_associated :person
end
