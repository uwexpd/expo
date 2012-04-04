# Represents a possible allocated service learning opportunity that a student can sign up for. Staff users allocate position slots to each ServiceLearningCourse by creating ServiceLearningPlacement records. Until a student signs up for the course, the placement is open (or, still considered an "opportunity"). Once a student has signed up, it becomes filled. 
# 
# For example, consider a ServiceLearningPosition called "Urban Planner Assistant" with 10 possible slots. Staff users decide to split up these spots between two courses: 8 slots to CEP 200 and 2 slots to AES 151. In that scenario, there will be 8 ServiceLearningPlacement records tied to CEP 200 and 2 ServiceLearningPlacement records tied to AES 151.
class ServiceLearningPlacement < ActiveRecord::Base
  include ActionController::UrlWriter
  
  stampable
  belongs_to :course, :class_name => "ServiceLearningCourse", :foreign_key => 'service_learning_course_id'
  belongs_to :position, :class_name => "ServiceLearningPosition"
  belongs_to :person
  has_one :evaluation, :as => :evaluatable
  acts_as_soft_deletable
  
  validates_presence_of :service_learning_position_id
  
  delegate :title, :organization, :to => :position
  delegate :fullname, :to => :person
  
  after_save :update_service_learning_position_counts
  after_destroy :update_service_learning_position_counts
  
#  before_save :ensure_evaluation_exists

  PLACEHOLDER_CODES = %w(evaluation_submitted? update_placement_quarter_link)
  PLACEHOLDER_ASSOCIATIONS = %w(position position.organization position.quarter person course)

  # Used as an alternative title. Returns a student name if this placement is filled.
  def subidentifier_string
    person.fullname if person
  end

  def <=>(o)
    person <=> o.person rescue 1
  end
  
  # Returns true if a person has been assigned to this placement or not.
  def filled?
    !person_id.blank?
  end
  
  # Returns true if this placement has been allocated to a course.
  def allocated?
    !service_learning_course_id.blank?
  end
  
  # Inverse of #allocated.
  def unallocated?
    !allocated?
  end
  
  # Returns true if the evaluation for this placement has been submitted.
  def evaluation_submitted?
    return false if evaluation.nil?
    evaluation.submitted?
  end

  # Sets +person_id+ to +nil+
  def unplace_student!
    update_attribute(:person_id, nil)
  end
  
  def update_placement_quarter_link
    pipeline_update_placement_quarter_url(:host => CONSTANTS[:base_url_host], :id => id)
  end
  
  protected
  
  def update_service_learning_position_counts
    position.update_placement_counts!
  end
  
end
