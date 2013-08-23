class MustBeValidEmailAddressValidation < OfferingQuestionValidation
  
  def allows?(application_for_offering)
    MustBeValidEmailAddressValidation.valid_email_address(get_answer(application_for_offering))
  end

  def generic_error_message
    "must be a valid e-mail address."
  end

  def self.valid_email_address(email)
    format = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
    format.match(email.try(:downcase)) ? true : false
  end
  

end
