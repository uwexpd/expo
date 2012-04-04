# Models an appointment (scheduled or drop-in) between a staff person and a student.
class Appointment < ActiveRecord::Base
  
  belongs_to :staff_person, :class_name => "Person", :foreign_key => "staff_person_id"
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  belongs_to :unit
  belongs_to :previous_appointment, :class_name => "Appointment", :foreign_key => "previous_appointment_id"
  belongs_to :contact_type, :foreign_key => "contact_type_id"
  
  validates_presence_of :start_time, :unit_id
  validates_presence_of :staff_person_id, :student_id, :unless => Proc.new { |a| a.is_a?(QuickContact) }
  validates_exclusion_of :student_id, :in => [0], :message => "cannot have an ID of zero"
  
  attr_accessor :student_search
  
  named_scope :without_quick_contacts, :conditions => {:type => nil}
  
  # Default sort is by start_time
  def <=>(o)
    start_time <=> o.start_time rescue 0
  end
  
  # Checks the student in for this appointment using the current Time as the checkin time. Override with another time if needed.
  def checkin!(time = Time.now)
    self.update_attribute(:check_in_time, time)
  end
  
  # Returns true if the check_in_time is not nil
  def checked_in?
    !check_in_time.blank?
  end
  
  # Handles when the 'student_search' field is supplied. Searches using Student#find_by_anything and inputs the resulting
  # Student ID value into +student_id+
  def student_search=(q)
    return false if q.nil? || q.blank? || q == "0"
    s = Student.find_or_create_by_system_key(q)
    self.student_id = s.id unless s.nil?
  end
  
end
