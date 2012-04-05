class OfferingInterview < ActiveRecord::Base
  stampable
  belongs_to :offering
  has_many :interviewers, :class_name => "OfferingInterviewInterviewer", :dependent => :nullify
  has_many :offering_interviewers, :through => :interviewers, :source => :offering_interviewer
  has_many :applicants, :class_name => "OfferingInterviewApplicant", :dependent => :destroy
  has_many :application_for_offerings, :through => :applicants, :source => :application_for_offering
  
#  validates_uniqueness_of :start_time, :scope => :offering_id
  validates_presence_of :start_time
  
  attr_accessor :applicant_id, :interviewer
  
  # Returns the ID of the application_for_offering of the currently selected applicant for this Interview. Note that this might 
  # seem a bit odd given the data structure; the database is arranged to allow for multiple applicants per interview in case that 
  # feature was ever desired, but the code itself only expects a single applicant per Interview.
  def applicant_id
    applicants.empty? ? nil : applicants.first.application_for_offering_id
  end
  
  def start_time_pretty
    start_time.strftime("%A, %B %d %I:%M %p")
  end
  
  def interviewer_list(delimiter = ", ")
    offering_interviewers.collect {|i| i.person.fullname }.join(delimiter)
  end
  
  def applicant
    applicants.empty? ? nil : applicants.first.application_for_offering
  end
  
  # Returns a textual representation of the current state of the decision for this interview. Valid return values include:
  # - Waiting: the interview is complete but no decision has been entered
  # - Not Started: The interview has not yet taken place
  # - Yes, No, Yes with contingency, etc.: The final decision in text form
  def decision
    if applicant.nil?
      nil
    else
      if applicant.interview_decision_made?
        applicant.interview_committee_decision
      else
        time_passed? ? "Waiting" : "Not Started"
      end
    end
  end
  
  def end_time_for_applicants
    interview_length = offering.interview_time_for_applicants || 30
    start_time + interview_length.minutes
  end
  
  def end_time_for_interviewers
    interview_length = offering.interview_time_for_interviewers || 45
    start_time + interview_length.minutes
  end

  def time_passed?
    end_time_for_interviewers < Time.now
  end

end
