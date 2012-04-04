# Defines an Evaluation of a specific object. Any object can be "evaluatable" through a polymorphic association, but it was originally created for service-learning evaluations from community partners. Each Evaluation has multiple EvaluationResponses, which are connected to EvaluationQuestions.
class Evaluation < ActiveRecord::Base
  stampable
  has_many :responses, :class_name => "EvaluationResponse"
  belongs_to :evaluatable, :polymorphic => true
  belongs_to :completer, :class_name => "Person", :foreign_key => "completer_person_id"
  
  validates_associated :responses

  # Finds the EvaluationResponse that corresponds to the given EvaluationQuestion. If none found, creates one.
  def response_for(question)
    responses.find_by_evaluation_question_id(question) || responses.build(:evaluation_question_id => question.id)
  end
  
  # Saves a response for this Evaluation.
  def response=(response_attributes)
    response_attributes.each do |id, attributes|
      response_for(EvaluationQuestion.find(id)).update_attribute(:response, attributes[:response])
    end
  end
  
  # Returns true if this Evaluation has a non-nil +submitted_at+ date.
  def submitted?
    !submitted_at.nil?
  end
  
  # Returns true if someone other than the position supervisor completed this evaluation.
  def completed_by_non_supervisor?
    !completer_name.blank?
  end
  
  # Marks the evaluation as not submitted
  def unsubmit
    update_attribute(:submitted_at, nil)
  end
end
