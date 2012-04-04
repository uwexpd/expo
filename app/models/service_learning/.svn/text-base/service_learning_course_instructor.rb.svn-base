# A ServiceLearningCourse has one or more ServiceLearningCourseInstructors. See note at ServiceLearningCourse.
class ServiceLearningCourseInstructor < ActiveRecord::Base
  stampable
  belongs_to :service_learning_course
  belongs_to :person
  
  validates_presence_of :service_learning_course_id
  validates_presence_of :person_id
  validates_associated :person
  
  delegate :fullname, :contact_histories, :to => :person

  PLACEHOLDER_CODES = %w(type_of_instructor)
  PLACEHOLDER_ASSOCIATIONS = %w(person service_learning_course)

  def uw_netid
    nil
  end
  
  def uw_netid=(new_uw_netid)
    unless new_uw_netid.blank?
      user = PubcookieUser.authenticate(new_uw_netid)
      update_attribute(:person_id, user.person.id)
    end
  end
  
  def person_attributes=(person_attributes)
    person_attributes.merge!({:require_validations => true})
    if !person_attributes[:id].blank?
      update_attribute(:person_id, person_attributes[:id])
      person.update_attributes(person_attributes)
    elsif person.nil?
      build_person(person_attributes)
      person.save
      # update_attribute(:person_id, person.id)
    else
      person.update_attributes(person_attributes)
    end
  end
  
  # Returns a textual representation for the type of instructor this person is. Either 'instructor' or 'TA'.
  def type_of_instructor
    ta? ? "TA" : "instructor"
  end
  
end
