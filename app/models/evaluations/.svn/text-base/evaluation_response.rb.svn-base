# An answer to an EvaluationQuestion, typically grouped via an Evaluation object.
class EvaluationResponse < ActiveRecord::Base
  stampable
  belongs_to :evaluation
  belongs_to :question, :class_name => "EvaluationQuestion"
  
  validates_presence_of :evaluation_id
  validates_presence_of :evaluation_question_id
  
  validates_presence_of :response, :if => proc { |obj| obj.question.required? }
  
end
