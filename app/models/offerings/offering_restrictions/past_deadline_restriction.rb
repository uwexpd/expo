# Checks that the deadline for this Offering has not passed.    
class PastDeadlineRestriction < OfferingRestriction
  
  def allows?(application_for_offering)
    !self.offering.past_deadline? || application_for_offering.submitted?
  end

  def title
    "Past Deadline"
  end

  def detail
    "The deadline to submit this application was #{self.offering.deadline_pretty}.  If you feel that you have reached this message in error, please contact the program staff."
  end

end
