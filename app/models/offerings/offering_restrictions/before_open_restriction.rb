# Checks that we're passed the "open_date" for this Offering.
class BeforeOpenRestriction < OfferingRestriction
  
  def allows?(application_for_offering)
    self.offering.open_date < Time.now  #|| application_for_offering.submitted?
  end

  def title
    "Application not yet open"
  end

  def detail
    "This application process has not yet opened. If you feel that you have reached this message in error, please contact the program staff."
  end

end
