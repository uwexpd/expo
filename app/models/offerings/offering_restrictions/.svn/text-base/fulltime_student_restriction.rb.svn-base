class FulltimeStudentRestriction < OfferingRestriction
  
  def allows?(application_for_offering)
    @person = application_for_offering.person
    @person.full_time?(self.offering.quarter_offered)
  end

  def title
    "You must be a full-time student."
  end

  def detail
    "In order to apply for the #{self.offering.name}, you must be registered as a full-time student at the #{CONSTANTS[:university_name]}.  Since you are only currently registered for #{@person.current_credits(self.offering.quarter_offered) rescue "unknown"} credits, you cannot apply for this scholarship."
  end
  
end
