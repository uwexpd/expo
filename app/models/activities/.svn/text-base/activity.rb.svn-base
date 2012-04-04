=begin rdoc
An Activity models a person's participation in some sort of trackable activity. The primary purpose of the Activity models is to compile and generate accountability statistics for the provost and the legislature. We currently focus on two metrics for undergraduates: public service and research.

== How activities are stored
Activity is subclassed by a number of Activity varieties:

ActivityCourse::    for tracking an entire UW course for a particular quarter
ActivityProject::   for tracking an ongoing project, such as Students in Service, that lasts several weeks or even several quarters
ActivityEvent::     for tracking a one-time event, such as the MLK Day of Service, that has a more limited scope.
=end
class Activity < ActiveRecord::Base
  stampable

  belongs_to :department
  
  validates_presence_of :activity_type_id
  validates_associated :quarters
  has_many :quarters, :class_name => "ActivityQuarter", :dependent => :destroy

  # The number of "real" hours of activity that each course credit should be counted for.
  COURSE_CREDIT_TO_HOURS_MULTIPLIER = 3
  
  # The number of weeks in a quarter.
  WEEKS_PER_QUARTER = 10

  # The number of total hours for a quarter that a ServiceLearningPlacement should count for.
  SERVICE_LEARNING_PLACEMENT_NUMBER_OF_HOURS = 20
  
  named_scope :for_quarter, lambda { |q|
    { :select => "DISTINCT activities.*", 
      :conditions => { :quarter_id => q.id }}
  }

  named_scope :of_type, lambda { |t|
    { :select => "DISTINCT activities.*", 
      :conditions => { :activity_type_id => (t.is_a?(String) ? ActivityType.find_by_abbreviation(t).id : (t.is_a?(ActivityType) ? t.id : t)) }}
  }

  # Calculates the number of hours for a given activity.
  def self.number_of_hours(source)
    return source.number_of_hours if source.respond_to?(:number_of_hours)
    h = case
    when source.is_a?(StudentRegistrationCourse)
      source.credits * COURSE_CREDIT_TO_HOURS_MULTIPLIER * WEEKS_PER_QUARTER
    when source.is_a?(ServiceLearningPlacement)
      SERVICE_LEARNING_PLACEMENT_NUMBER_OF_HOURS    
    end
    h
  end

end



