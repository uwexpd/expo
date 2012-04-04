class StateResidentRestriction < OfferingRestriction
  
  def allows?(application_for_offering)
    @person = application_for_offering.person
    @person.washington_state_resident?
  end

  def title
    "You must be a Washington state resident."
  end

  def detail
    "In order to apply for the #{self.offering.name}, you must be a Washington state resident as determined by the Office of the Registrar."
  end
  
end
