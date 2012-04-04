class SympThreeMigrateController  < ActionController::Base
	# Values that might be needed to create the Years Symposium Offering
	OPEN_DATE = "2003-02-01 17:00:00" # Find out actual date
	UNIT_ID = 3
	COMMITTEE_ID = 4
	
	# Values that are already in the DB that will be used
	# From application type table
	POSTER_TYPE_ID = 7
	ORAL_PRES_TYPE_ID = 8
	EVENT_TYPE_ID = 1
	
	# Application status type = Confirmed
	APP_STATUS_TYPE_ID = 49
	
	STDOUT.sync = true
	
	# This will handle the 2008, 2007, 2006, 2005, and 2004 tables
	def run_migration(groups = SympThreeGroup.all, year = 2003)
		Offering.transaction do
			start_time = "2003-05-16 12:00:00"
			end_time = "2003-05-16 17:00:00" 
			# Incase we need to run the migration on more data from the same year it will use the same offering
			offering = Offering.find(:first, :conditions => {:name => "#{year} Undergraduate Research Symposium"})
			offering = create_offering(start_time, end_time, year) if offering.nil?
			groups.each do |group|
				puts group.GroupID
				create_application(group, offering, start_time)
			end
			offering.application_for_offerings_count = offering.application_for_offerings.size
			
			offering.save!
			
		end
	end
	
	def create_offering(start_time, end_time, year)
		offering = Offering.new
		
		offering.name = "#{year} Undergraduate Research Symposium"
		offering.description = "The Research Symposium is an annual celebration of undergraduate scholarship and creativity."
		offering.uses_interviews = false
		offering.unit_id = UNIT_ID
		offering.year_offered = year
		offering.uses_non_committee_review = true
		offering.open_date = OPEN_DATE
		offering.deadline = OPEN_DATE
		offering.max_number_of_mentors = 4
		offering.min_number_of_mentors = 0
		offering.allow_students_only = false
		
		offering.save!
		
		offering.application_types << OfferingApplicationType.create(:application_type_id => POSTER_TYPE_ID)
		offering.application_types << OfferingApplicationType.create(:application_type_id => ORAL_PRES_TYPE_ID)
		
		offering.statuses << OfferingStatus.create(:public_title => "Participation Confirmed", :application_status_type_id => APP_STATUS_TYPE_ID)
		
		offering.events << Event.create(:title => "#{year} Undergraduate Research Symposium", :unit_id => UNIT_ID, :description => "The Research Symposium is an annual celebration of undergraduate scholarship and creativity.", :event_type_id =>EVENT_TYPE_ID)
		offering.events.first.times << EventTime.create(:start_time => start_time, :end_time => end_time, :location_text => "Mary Gates Hall")
		
		return offering
	end
	
	def create_application(group, offering, start_time)
		group_members = group.symp_three_student
		group_lead = group_members.pop
		unless group_lead.nil?
			group_member = get_group_member_record(group_lead)
			symposium_app = ApplicationForOffering.new
			symposium_app.offering_id = offering.id
			symposium_app.person_id = group_member.id
			symposium_app.project_title = group.ProjTitle
			symposium_app.project_description = group.ProjTitle
			if group.Participation.strip.downcase == "poster"
				symposium_app.application_type_id = POSTER_TYPE_ID
			else
				symposium_app.application_type_id = ORAL_PRES_TYPE_ID
			end
			
			symposium_app.save!
			
			symposium_app.statuses << ApplicationStatus.new(:application_status_type_id => APP_STATUS_TYPE_ID)
			symposium_app.current_application_status = symposium_app.statuses.last
			
			offering.events.first.times.first.invite!(symposium_app, {:attending => true, :checkin_time => start_time})
			
			group_members.each do |current_group_member|
				group_member = get_group_member_record(current_group_member)
				group_member_connect = ApplicationGroupMember.new
				group_member_connect.application_for_offering_id = symposium_app.id
				group_member_connect.firstname = group_member.firstname
				group_member_connect.lastname = group_member.lastname
				group_member_connect.verified = true
				group_member_connect.confirmed = true
				if group_member.is_a?(Student)
					group_member_connect.uw_student = true
					group_member_connect.email = group_member.email.split('@')[0]
				else
					group_member_connect.uw_student = false
					group_member_connect.email = group_member.email
					group_member_connect.person_id = group_member.id
				end
				group_member_connect.save!
				offering.events.first.times.first.invite!(group_member_connect, {:attending => true, :checkin_time => start_time})
			end
			
			find_info = {:firstname => group.Fac1Fname, :lastname => group.Fac1Lname, :email => group.Fac1Email, :salutation => " "}
			add_mentor(symposium_app, find_info, group.Fac1Dept)
			
			unless (group.Fac2Fname.nil?)
				find_info = {:firstname => group.Fac2Fname, :lastname => group.Fac2Lname, :email => group.Fac2Email, :salutation => " "}
				add_mentor(symposium_app, find_info, group.Fac2Dept)
			end
			
			if group.read_attribute("Session Title").nil?
				session = offering.sessions.find(:first,:conditions => {:title => "2003 Symposium Poster Session"})
			else
				session = offering.sessions.find(:first,:conditions => {:title => group.read_attribute("Session Title")})
			end
			if session.nil?
				if group.read_attribute("Session Title").nil?
					session = OfferingSession.create(:finalized => true, :offering => offering, :title => "2003 Symposium Poster Session", :start_time => start_time, :end_time => (start_time.to_time + 5.hours))
				else
					session = OfferingSession.create(:finalized => true, :offering => offering, :title => group.read_attribute("Session Title"), :start_time => start_time, :end_time => (start_time.to_time + 5.hours))
				end
				found_moderator = find_committee_member(group)
				session.moderator_id = found_moderator.id if found_moderator
			end
			session.save!
			symposium_app.offering_session_id = session.id
			
			
			symposium_app.save!
		end
	end
	
	# For 2003 everyone should be a UW student so we will just find a Student
	def get_group_member_record(group_member)
		student = nil
		
		special_university_ids = {4 => 4044, 5 => 4554, 6 => 4597, 7 => 4695, 8 => 4292, 10 => 4705, 11 => 4947, 15 => 4694}
		unless group_member.UniversityID.nil?
			student = Person.new
			student.firstname = group_member.Fname
			student.lastname = group_member.Lname
			student.email = group_member.Email
			student.institution_id = special_university_ids[group_member.UniversityID.to_i]
		end
		
		if student.nil?
			student = Student.find_by_student_no(group_member.StNum)
			
			if student.nil?
				puts "student number is not right looking by email"
				if (group_member.Email =~ /washington.edu/)
					netid = group_member.Email.split('@')[0]
					student = Student.find_by_uw_netid(netid)
				end
			end
			if student.nil?
				puts group_member.StNum
				puts group_member.Email
				puts "student number is not right and email was not a UW one"
				student = Person.new
				student.firstname = group_member.Fname
				student.lastname = group_member.Lname
				student.email = group_member.Email
			end
		end
		
		student.save!
		return student
	end
	
	def add_mentor(symposium_app, find_info, mentor_dept)
		puts "finding a group mentor"
		
		mentor = Person.find_or_create_by_best_guess(find_info)
		#puts mentor.inspect
		tempMentor = ApplicationMentor.new
		tempMentor.application_for_offering_id = symposium_app .id
		tempMentor.person_id = mentor.id
		tempMentor.firstname = mentor.firstname
		tempMentor.lastname = mentor.lastname
		tempMentor.email = mentor.email
		
		puts tempMentor.firstname
		puts tempMentor.lastname
		tempMentor.save!

		tempMentor.person.other_department = mentor_dept
		
		tempMentor.person.save!
	end
	
	def find_committee_member(group)
		committee = Committee.find_by_id COMMITTEE_ID
		found_member = nil
		found_once = 0
		committee.members.each do |member|
			if group.read_attribute("Session Moderator") &&
					member.person.lastname.split(" ").last.downcase == group.read_attribute("Session Moderator").split(" ").last.downcase &&
					member.person.firstname.split(" ").first.downcase == group.read_attribute("Session Moderator").split(" ").first.downcase
				found_once = found_once + 1
				found_member = member
			end
		end
		if found_once == 0 or found_once > 1
			puts "moderator was either not found by name or found more than once by name"
			puts group.read_attribute("Session Moderator")
			puts found_once
			return nil
		end
		return found_member
	end
end






























