class MustBeNumberValidation < OfferingQuestionValidation
  
  def allows?(application_for_offering)
    get_answer(application_for_offering).to_f != 0
  end

  def generic_error_message
    "must be a number"
  end

end
