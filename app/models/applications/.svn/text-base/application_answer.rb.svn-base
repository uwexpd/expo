class ApplicationAnswer < ActiveRecord::Base
  stampable
  belongs_to :application_for_offering
  belongs_to :offering_question
  belongs_to :question, :class_name => "OfferingQuestion", :foreign_key => "offering_question_id"
  acts_as_soft_deletable
  
end
