# Tracks a person's availability for a specific OfferingInterviewTimeblock. This is used to facilitate the automation of the interview scheduling process. Note that the applicant's or interviewer's _actual_ interview time is stored in Interview.
# 
# An InterviewAvailability record stores the beginning of a time period that a person is available. Currently, that time period is 15 minutes. So if an InterviewAvailability time is 09:15 then the person is available from 09:15:00 until 09:29:59. There is a separate record for each 15-minute time period, so if a person is available for an hour, they will have four individual InterviewAvailability records which compose that hour.
# 
# InterviewAvailability stores application_for_offering_id as well as offering_interviewer_id, which allows us to identify the person that this availability is for. Only one of these fields should be specified. 
class InterviewAvailability < ActiveRecord::Base
  stampable
  belongs_to :offering_interview_timeblock
  belongs_to :application_for_offering
  belongs_to :offering_interviewer
  
  # Returns what type of person this availability is for; either "applicant" or "interviewer"
  def person_type
    offering_interviewer.nil? ? 'applicant' : 'interviewer'
  end
  
end
