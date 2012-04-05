# Defines a question that an EvaluationResponse answers. We use a polymorphic association here so that any object can define many EvaluationQuestions that it would like to ask when being evaluated. For example, a Quarter object may have a number of "service_learning_evaluation_questions" and a CommunityPartner can submit an Evaluation for a student which answers these questions through EvaluationResponses.
class EvaluationQuestion < ActiveRecord::Base
  stampable
  belongs_to :evaluation_questionable, :polymorphic => true
end
