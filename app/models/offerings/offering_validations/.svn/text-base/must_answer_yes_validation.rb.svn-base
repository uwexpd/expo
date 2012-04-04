class MustAnswerYesValidation < OfferingQuestionValidation
  
  def allows?(application_for_offering)
    get_answer(application_for_offering) == true
  end

  def generic_error_message
    "must be answered Yes"
  end

end
