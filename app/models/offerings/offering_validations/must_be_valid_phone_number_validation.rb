class MustBeValidPhoneNumberValidation < OfferingQuestionValidation
  
  def allows?(application_for_offering)
    text = get_answer(application_for_offering)
    !text.nil? && text.size >= 10
  end

  def generic_error_message
    "must have at least ten digits"
  end

end