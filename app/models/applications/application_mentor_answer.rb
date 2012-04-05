# An ApplationMentor's answer to a specific OfferingMentorQuestion.
class ApplicationMentorAnswer < ActiveRecord::Base
  stampable
  belongs_to :question, :class_name => "OfferingMentorQuestion", :foreign_key => "offering_mentor_question_id"
  delegate :offering, :to => :question
  belongs_to :application_mentor
  
  validates_uniqueness_of :offering_mentor_question_id, :scope => :application_mentor_id
  
  validates_presence_of :answer, :if => Proc.new { |a| !a.skip_validations && a.required? }
  delegate :required?, :to => :question
  
  validates_numericality_of :answer, :if => Proc.new { |a| !a.skip_validations && a.must_be_number? }
  delegate :must_be_number?, :to => :question
  
  attr_accessor :skip_validations
  
end
