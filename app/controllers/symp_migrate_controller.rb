class SympMigrateController  < ActionController::Base
	# Values that might be needed to create the Years Symposium Offering
	OPEN_DATE = "2008-02-01 17:00:00" # Find out actual date
	UNIT_ID = 3
	COMMITTEE_ID = 4
	
	# Valuse that are already in the DB that will be used
	# From application type table
	POSTER_TYPE_ID = 7
	ORAL_PRES_TYPE_ID = 8
	EVENT_TYPE_ID = 1
	
	# Application status type = Confirmed
	APP_STATUS_TYPE_ID = 49
	
	STDOUT.sync = true
	
	# This will handle the 2008, 2007, 2006, 2005, and 2004 tables
	def run_migration(year, groups = SympGroup.all)
		Offering.transaction do
			if year == 2008
				start_time = "2008-05-16 12:00:00"
				end_time = "2008-05-16 17:00:00"
			elsif year == 2007
				start_time = "2007-05-18 12:00:00"
				end_time = "2007-05-18 17:00:00"
			elsif year == 2006
				start_time = "2006-05-19 12:00:00"
				end_time = "2006-05-19 17:00:00"
			elsif year == 2005
				start_time = "2005-05-13 12:00:00"
				end_time = "2005-05-13 17:00:00"
			elsif year == 2004
				start_time = "2004-05-14 12:00:00"
				end_time = "2004-05-14 17:00:00"
			else
				puts "year was not passed"
				raise # Stop the migration
			end
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
		offering.open_date = start_time
		offering.deadline = start_time
		offering.max_number_of_mentors = 4
		offering.min_number_of_mentors = 0
		offering.allow_students_only = false
		offering.theme_response_title = "Haiku" if year == 2006
		
		offering.save!
		
		offering.application_types << OfferingApplicationType.create(:application_type_id => POSTER_TYPE_ID)
		offering.application_types << OfferingApplicationType.create(:application_type_id => ORAL_PRES_TYPE_ID)
		
		offering.statuses << OfferingStatus.create(:public_title => "Participation Confirmed", :application_status_type_id => APP_STATUS_TYPE_ID)
		
		offering.events << Event.create(:title => "#{year} Undergraduate Research Symposium", :unit_id => UNIT_ID, :description => "The Research Symposium is an annual celebration of undergraduate scholarship and creativity.", :event_type_id =>EVENT_TYPE_ID)
		
		offering.events.first.times << EventTime.create(:start_time => start_time, :end_time => end_time, :location_text => "Mary Gates Hall")
		
		return offering
	end
	
	def create_application(group, offering, start_time)
		group_members = group.symp_student
		group_lead = group_members.pop
		unless group_lead.nil?
			# Create the inital Application for the Group
			group_member = get_group_member_record(group_lead)
			symposium_app = ApplicationForOffering.new
			symposium_app.offering_id = offering.id
			symposium_app.person_id = group_member.id
			symposium_app.project_title = offering.year_offered < 2007 ? group.Title : group.ShortTitle
			symposium_app.project_description = group.Title
			symposium_app.theme_response = group.Haiku if offering.year_offered == 2006
			if group.PresentationType.strip == "poster"
				symposium_app.application_type_id = POSTER_TYPE_ID
			else
				symposium_app.application_type_id = ORAL_PRES_TYPE_ID
			end
			
			symposium_app.save!
			
			symposium_app.statuses << ApplicationStatus.new(:application_status_type_id => APP_STATUS_TYPE_ID)
			symposium_app.current_application_status = symposium_app.statuses.last
			
			offering.events.first.times.first.invite!(symposium_app, {:attending => true, :checkin_time => start_time})
			
			# Add in Group Members
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
			
			group.symp_mentor.each do |current_group_mentor|
				add_mentor(symposium_app, current_group_mentor)
			end
			
			# Add in Sessions
			if symposium_app.application_type_id == ORAL_PRES_TYPE_ID
				if offering.year_offered == 2005 || offering.year_offered == 2004
					#session = offering.sessions.find(:first,:conditions => {:title => group.symp_session.SessionTitle})
					#if session.nil?
					#	session = OfferingSession.create(:finalized => true, :offering => offering, :title => group.symp_session.SessionTitle, :start_time => start_time, :end_time => (start_time.to_time + 5.hours))
					#end
					#session.save!
					#symposium_app.offering_session_id = session.id
				else
					offset = 1.hour
					offser = (3.hour + 30.minutes) if group.PresentTime == "3:30"
					session = offering.sessions.find(:first,:conditions => {:title => group.symp_assigned_session.SessionTitle})
					if session.nil?
						session = OfferingSession.create(:finalized => true, :offering => offering, :title => group.symp_assigned_session.SessionTitle, :start_time => (start_time.to_time + offset), :end_time => (start_time.to_time + offset + 1.hour + 30.minutes))
						found_moderator = find_committee_member(group)
						session.moderator_id = found_moderator.id if found_moderator
					end
					session.save!
					symposium_app.offering_session_id = session.id
				end
			else
				if offering.year_offered == 2008
					offset = 0.hour
					offser = (2.hour + 30.minutes) if group.PresentTime == "2:30"
					session = offering.sessions.find(:first,:conditions => {:title => "#{offering.year_offered} #{group.PresentTime} Symposium Poster Session"})
					if session.nil?
						session = OfferingSession.create(:finalized => true, :offering => offering, :title => "#{offering.year_offered} #{group.PresentTime} Symposium Poster Session", :start_time => (start_time.to_time + offset), :end_time => (start_time.to_time + offset + 2.hours + 30.minutes))
					end
					session.save!
					symposium_app.offering_session_id = session.id
				else
					session = offering.sessions.find(:first,:conditions => {:title => "#{offering.year_offered} Symposium Poster Session"})
					if session.nil?
						session = OfferingSession.create(:finalized => true, :offering => offering, :title => "#{offering.year_offered} Symposium Poster Session", :start_time => (start_time.to_time), :end_time => (start_time.to_time + 5.hours))
					end
					session.save!
					symposium_app.offering_session_id = session.id
				end
			end
			
			symposium_app.save!
		end
	end
	
	# This will return either a Student record for a UW student or a Person record for a non UW student
	def get_group_member_record(group_member)
		special_student_nos = {1100111 => 4044, 1100222 => 4554, 1100333 => 4597, 1100444 => 4695, 1100555 => 4292, 1100777 => 4705, 1100888 => 4947}
		special_university_ids = {4 => 4044, 5 => 4554, 6 => 4597, 7 => 4695, 8 => 4292, 10 => 4705, 11 => 4947, 15 => 4694}
		univertisy_abbrs = {"W.W.U." => 4947, "T.E.S.C." => 4292, "S.U." => 4695, "S.P.U." => 4694, "N.S.C.C." => 4554}
		university_ids = [01, 02, 03]
		university_names = ["UW-Bothell", "UW-Seattle", "UW-Tacoma"]
		student = nil
		
		if (group_member.Email =~ /washington.edu/) || university_ids.include?(group_member.UniversityID.to_i) || university_names.include?(group_member.UniversityID.to_s)
			# They have a UW email
			student = Student.find_by_student_no(group_member.StudentNo)
			if student.nil?
				netid = group_member.Email.split('@')[0]
				student = Student.find_by_uw_netid(netid)
			end
		end
		if student.nil?
			student = Person.new
			student.firstname = group_member.FirstName
			student.lastname = group_member.LastName
			student.email = group_member.Email
			if group_member.UniversityID.to_i == 0
				student.institution_id = univertisy_abbrs[group_member.UniversityID.to_s]
			else
				student.institution_id = special_student_nos[group_member.StudentNo.to_i]
				if student.institution_id.nil?
					student.institution_id = special_university_ids[group_member.UniversityID.to_i]
				end
			end
		end
		student.save!
		return student
	end
	
	def add_mentor(symposium_app, current_group_mentor)
		puts "finding a group mentor"
		
		find_info = {:firstname => current_group_mentor.FirstName, :lastname => current_group_mentor.LastName, :email => current_group_mentor.Email, :salutation => " "}
		mentor = Person.find_or_create_by_best_guess(find_info)
		#puts mentor.inspect
		tempMentor = ApplicationMentor.new
		tempMentor.application_for_offering_id = symposium_app .id
		tempMentor.person_id = mentor.id
		tempMentor.firstname = mentor.firstname
		tempMentor.lastname = mentor.lastname
		tempMentor.email = mentor.email
		
		
		tempMentor.save!
		
		puts "#{tempMentor.firstname} #{tempMentor.lastname}"
		puts ""
		
		if current_group_mentor.symp_department
			if current_group_mentor.symp_department.Real_id
				tempMentor.person.department_id = current_group_mentor.symp_department.Real_id
			else
				tempMentor.person.other_department = current_group_mentor.symp_department.Department
			end
		end
		
		tempMentor.person.save!
	end
	
	def find_committee_member(group)
		committee = Committee.find_by_id COMMITTEE_ID
		found_member = nil
		found_once = 0
		committee.members.each do |member|
			if group.symp_assigned_session.ModeratorName &&
					member.person.lastname.split(" ").last.downcase == group.symp_assigned_session.ModeratorName.split(" ").last.downcase && 
					member.person.firstname.split(" ").first.downcase == group.symp_assigned_session.ModeratorName.split(" ").first.downcase
				found_once = found_once + 1
				found_member = member
			end
		end
		if found_once == 0 or found_once > 1
			puts "moderator was either not found by name or found more than once by name"
			puts group.symp_assigned_session.ModeratorName
			puts found_once
			return nil
		end
		return found_member
	end
	
end






























