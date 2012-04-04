class MustBeWholeNumberValidation < OfferingQuestionValidation
  
  def allows?(application_for_offering)
    answer = get_answer(application_for_offering)
    answer == answer.to_i.to_s && answer.to_i != 0
  end

  def generic_error_message
    "must be a whole number"
  end

end
