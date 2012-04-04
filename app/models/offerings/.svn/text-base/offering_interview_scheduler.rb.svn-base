class OfferingInterviewScheduler
  
  @timeslots
  @offering
  @applications_for_interview
  @interviewers

  def initialize(offering)

    @offering = offering
    @applications_for_interview = @offering.applications_for_interview
    @interviewers = @offering.interviewers
    @timeslots = Array.new

    # create timeslot objects
    @offering.interview_timeblocks.each do |b|
    	(b.start_time .. b.end_time).each do |t|
    		if t.sec == 0 && t.min%15==0
    			timeslot = OfferingInterviewTimeslot.new
    			timeslot.timeblock = b
    			timeslot.time = t
    			timeslot.offering = @offering
    			timeslot.add_applicants(@applications_for_interview)
    			timeslot.add_interviewers(@interviewers)
    			@timeslots.push timeslot
    		end
    	end
    end

    # run the rules
    @timeslots.each {|t| t.remove_recused_interviewers }
    @timeslots.delete_if {|t| t.interviewers.size < 3 }
    @timeslots.delete_if {|t| t.applicants.size < 1 }
    # @timeslots.delete_if {|t| t.experienced_interviewer_count < 1 }
    # @timeslots.delete_if {|t| t.on_campus_interviewer_count < 1 }
  end

  def timeslots_for(applicant)
    times = @timeslots.reject {|t| !t.includes_applicant? applicant }
  end
  
  def timeslots
    @timeslots
  end
  
end