class MustBeValidNetidValidation < OfferingQuestionValidation
  
  def allows?(application_for_offering)
    MustBeValidNetidValidation.valid_uwnetid(get_answer(application_for_offering))
  end

  def generic_error_message
    "must be a valid UW NetId."
  end

  def self.valid_uwnetid(uwnetid)
    # strip out the '@uw.edu' if someone tries that
    uwnetid = uwnetid.to_s.match(/^(\w+)(@.+)?$/).try(:[], 1) 
    Student.find_by_uw_netid(uwnetid).nil? ? false : true
  end
  

end
