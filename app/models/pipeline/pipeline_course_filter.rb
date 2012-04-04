=begin rdoc
  This allows you to apply filters to a service learning course from that admin side that are forced on the student side
=end
class PipelineCourseFilter < ActiveRecord::Base
  
  #belongs_to :filter, :polymorphic => true
  belongs_to :service_learning_course
  serialize :filters
  
  validates_uniqueness_of :service_learning_course_id
  
end