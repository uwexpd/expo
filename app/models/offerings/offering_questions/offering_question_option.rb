class OfferingQuestionOption < ActiveRecord::Base
  stampable
  belongs_to :offering_question

  validates_presence_of :offering_question_id, :title
  
  def value
    read_attribute(:value).blank? ? title : read_attribute(:value)
  end
  
  def associate?
    return !associate_question_id.nil?
  end
  
  def associate_question
    offering_question.find(associate_quesiton_id) if associate?
  end
  
end
