class GpaRestriction < OfferingRestriction
  
  validates_presence_of :parameter, :message => "must list the minimum GPA to require"
  
  def allows?(application_for_offering)
    @person = application_for_offering.person
    @person.gpa.to_f >= parameter.to_f
  end

  def title
    "You must have a cumulative GPA of #{parameter.to_s}."
  end

  def detail
    "In order to apply for the #{self.offering.name}, you must have earned a cumulative GPA of #{parameter.to_s}. Your GPA is #{@person.gpa rescue "unknown"} so you are not allowed to start an application."
  end
  
end
