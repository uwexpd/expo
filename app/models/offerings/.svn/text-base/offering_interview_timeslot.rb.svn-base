class OfferingInterviewTimeslot
  
  TIMESLOT_SIZE = 15
  
  @applicants = Array.new
  @interviewers = Array.new
  @offering
  @timeblock
  @time
  @priority
  
  attr_accessor :offering, :timeblock, :time
  
  def applicants
    @applicants
  end
  
  def interviewers
    @interviewers
  end
  
  def timestamp
    DateTime.parse("#{@timeblock.date} #{@time.strftime("%I:%M %p")}")
  end
  
  # Adds an applicant to the list of applicants that can validly attend an interview at this time. In order to be valid,
  # an applicant must be available for this timeslot as well as the next timeslot, for a total of 30 minutes.
  def add_applicant_if_valid(a, interview_length = 30)
    @applicants ||= Array.new
    if available? a, interview_length/TIMESLOT_SIZE
      @applicants << a unless @applicants.include? a
    end
  end
  
  def add_interviewer_if_valid(i, interview_length = 45)
    @interviewers ||= Array.new
    if available? i, interview_length/TIMESLOT_SIZE
      @interviewers << i unless @interviewers.include? i
    end
  end
  
  # Adds an array of applicants to the list of applicants
  def add_applicants(applicants)
    applicants.each do |a|
      add_applicant_if_valid(a)
    end
  end
  
  def add_interviewers(interviewers)
    interviewers.each do |i|
      add_interviewer_if_valid(i)
    end
  end

  # Returns the next timeslot in this timeblock or +nil+ if the next timeslot would be past the end_time for this timeblock.
  def next_time(num_timeslots = 1)
    next_time = @time + (TIMESLOT_SIZE.minutes * num_timeslots)
    next_time > @timeblock.end_time ? nil : next_time
  end
  
  # Returns true if the person is available for the current timeslot, or if num_timeslots is passed, returns true if the person
  # is available for current timeslot _and_ next +num_timeslots+ timeslots.
  def available?(person_record, num_timeslots = 1)
    return false unless person_record.available_for_interview? @time, @timeblock
    num_timeslots.times do |n|
      return false unless !next_time(num_timeslots).nil? && person_record.available_for_interview?(next_time(num_timeslots), @timeblock)
    end
    true
  end

  def includes_applicant?(app)
    @applicants.include? app
  end

  def applicant_list
    @applicants.collect {|a| a.person.fullname }.join('<br>')
  end

  def interviewer_list
    @interviewers.collect {|i| i.person.fullname }.join('<br>')
  end

  def remove_recused_interviewers
    @interviewers.each do |i|
      @applicants.each do |a|
        @interviewers.delete(i) if i.recused_from? a
      end
    end
  end

  def experienced_interviewer_count
    count = 0
    @interviewers.each do |i|
      count = count+1 unless i.first_time
    end
    count
  end
  
  def male_interviewer_count
    count = 0
    @interviewers.each do |i|
      count = count+1 if i.person.gender == 'M'
    end
    count
  end
  
  def female_interviewer_count
    count = 0
    @interviewers.each do |i|
      count = count+1 if i.person.gender == 'F'
    end
    count
  end

  def on_campus_interviewer_count
    count = 0
    @interviewers.each do |i|
      count = count+1 unless i.off_campus
    end
    count
  end

  def past_scholar_interviewer_count
    count = 0
    @interviewers.each do |i|
      count = count+1 if i.past_scholar
    end
    count
  end

  def calculate_priority
    
  end
  
end
