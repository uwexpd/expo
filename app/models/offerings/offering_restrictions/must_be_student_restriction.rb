class MustBeStudentRestriction < OfferingRestriction
  
  def allows?(application_for_offering)
    @person = application_for_offering.person
    @person.is_a? Student
  end

  def title
    "You must be logged in as a student."
  end

  def detail
    "In order to apply for the #{self.offering.name}, you must be logged in as a student at the #{CONSTANTS[:university_name]}.  You are currently logged in as a non-student user, so you cannot continue with this application."
  end
  
  
end
