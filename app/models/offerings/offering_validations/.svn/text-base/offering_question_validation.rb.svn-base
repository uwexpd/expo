class OfferingQuestionValidation < ActiveRecord::Base
  stampable
  belongs_to :offering_question
  validates_uniqueness_of :offering_question_id, :scope => "type"
  validates_presence_of :type, :message => "You must choose a validation type."
  
  def allows?(application_for_offering)
    true
  end
  
  def get_answer(application_for_offering)
    application_for_offering.instance_eval(offering_question.full_attribute_name)
  end
    
  def error_message
    custom_error_text.blank? ? generic_error_message : ": #{custom_error_text}"
  end
  
  def generic_error_message
  end
  
end
