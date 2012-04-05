class ApplicationReviewDecisionType < ActiveRecord::Base
  stampable
  has_many :assigned_applications, :class_name => "ApplicationForOffering", :foreign_key => "application_review_decision_type_id"
  belongs_to :application_status_type
  
  validates_presence_of :application_status_type_id
end
