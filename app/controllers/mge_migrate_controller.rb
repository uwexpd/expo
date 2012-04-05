
class MgeMigrateController  < ActionController::Base
	
	# Need to change these to reflect the actual vaules in the production DB
	EVENT_ID = 6 # Dont know if this will even be used
	EVENT_TIME_ID = 365 # ID of the event time for the 10 year party
	CHECK_IN_TIME = "2007-02-01 17:00:00"
	# IDs from Application Status Types table
	YES_INTERVIEW_ID = 16
	YES_ID = 33
	NO_ID = 39
	AWARDED_ID = 33 # Same as YES_ID
	NOT_INTERVIEW_ID = 35
	NOT_AWARDED_ID = 39 # Same as NO_ID
	#MGE Unit ID
	UNIT_ID = 2
	
	# Committee IDs
	MGE_RES_REV_COMM = 1
	OLD_MGE_REV_COMM = 5
	
	STDOUT.sync = true
	
	# command to use to get all needed student info
	# students = MgeStudent.get_student_migrate_info
	# Console steps:
	# mmc = MgeMigrateController.new
	# mmc.run_migration(students)
	
	# create event and event time
	# make new award type for mary gates travel grant
	
	# main method 
	# Pass in an array of records containing at leat these feilds: Student_key, St_Number, ten_yr_contact, ten_yr_notes, ten_year_attendee
	def run_migration(tempStudents)
		Offering.transaction do
			count = 0
			tempStudents.each do |tempStudent|
				
				student = Student.find_by_student_no(tempStudent.St_Number)
				
				unless student.nil?
					unless student.fullname.nil?
#						print " Adding: " + student.fullname
					end
					
					if tempStudent.ten_yr_contact == -1 || tempStudent.ten_year_attendee == -1 || !tempStudent.ten_yr_notes.nil?
						add_to_ten_year(student, tempStudent)
					end
					
					# Get the tempStudents' applications
					appls = tempStudent.applications
					unless appls.nil?
#						puts "    Found " + appls.count.to_s + " applications."
					else
#						puts "    They have no applications."
					end
					
					appls.each do |appl|
#						puts "        Processing application."
						award_info = MgeAward.get_award_info(appl.AWARD_TYPE) # Get award title and description
						quarter = Quarter.find_easily(appl.Quarter, appl.YEAR)  # Get the appropriate quarter id
						unless quarter.valid? # if it couldnt find the quarter id then try again
							puts quarter.inspect
							clean_quarter = appl.Q1_REQ.downcase.gsub(/\s/,'') # Removes any spaces
							if clean_quarter =~ /^[asw][ipu][0-9][0-9]$/
								# Change the year to the full year
								year_abbr = clean_quarter[2,2]
								year = case year_abbr.to_i
									when 0..10 then "20" + year_abbr
									else "19" + year_abbr
								end
								quarter = Quarter.find_easily(appl.Quarter, year) 
								puts quarter.inspect
							end
						end
						
						if quarter.valid?
							
							# First create an offering if needed
							offering = Offering.find(:first, :conditions => {:quarter_offered_id => quarter, :name => award_info.Award_title})
							
							if offering.nil?
								# Make a new offering
								offering = create_new_offering(award_info, quarter, appl)
							else
#								puts "          Offering found: #{offering.name}"
							end
							
							# Check for duplicate offerings and dont add if they exist
							appl_for_offering = ApplicationForOffering.find(:first, :conditions => {:offering_id => offering.id, :person_id => student.id})
							
							if appl_for_offering.nil?
								# Add application info to new application_for_offering
								appl_for_offering = create_new_application_for_offering(offering, student, appl)
							end
							
							# Add in Mentors and add in Reviewers
							# Get the MgeApplicationMentor records for the current original application (appl)
							reviewers_and_mentors = MgeApplicationMentor.reviewers_and_mentors_for_application(appl.Application_Key)
							reviewers_and_mentors.each do |reviewer_or_mentor|
								if reviewer_or_mentor.Status_Key == 1
									# It is a Mentor
#									puts "          Adding a Mentor"
									add_mentor(appl_for_offering , MgeMentor.get_mentor(reviewer_or_mentor.Mentor_Key))
								else
									# It is a Reviewer
#									puts "          Adding a Reviewer"
									add_reviewer(appl_for_offering , MgeMentor.get_mentor(reviewer_or_mentor.Mentor_Key), offering.id, reviewer_or_mentor, appl.AWARD_TYPE, appl.YEAR.to_i)
								end
							end
							
							# Set final decisions and add in application_statuses as needed
#							puts "          Setting Decisions"
							appl_for_offering = set_decisions(appl, offering, appl_for_offering)
							
							appl_for_offering.save! # Save the application
						else
							puts "could not find quarter id"
						end
					end
				else
					puts " "
					puts "could not find #{tempStudent.St_Number}"
				end
				
				count = count+1
				if count % 50 == 0
					puts ""
					print "#{count} - "
				elsif count % 10 == 0
					print "|"
				elsif count % 5 == 0
					print ":"
				elsif
					print "."
				end
				
			end
			#raise exception.new # Don't save the additions
		end
	end
	
	# IF –  tempStudent.ten_yr_contact is -1 – OR – tempStudent.ten_yr_notes is not NULL – OR – tempStudent.ten_year_attendee is -1
	# Adds the student to the event_invitees table for the ten year event
	def add_to_ten_year(student, tempStudent)
		did_they_check_in = nil
		if tempStudent.ten_year_attendee.abs == 1
			did_they_check_in = CHECK_IN_TIME
		end
		student.event_invites << EventInvitee.create(:event_time_id => EVENT_TIME_ID, :attending => tempStudent.ten_year_attendee.abs, :rsvp_comments => tempStudent.ten_yr_notes, :checkin_time => did_they_check_in)
	end
	
	# Creates a offering from the passed award_info and quarter_id
	def create_new_offering(award_info, quarter, appl)
		offering = Offering.create(:name => award_info.Award_title, :description => award_info.Award_description, :quarter_offered_id => quarter.id, :unit_id => UNIT_ID)
#		puts "          Created " + offering.name + " offering for quarter id: " + offering.quarter_offered_id .to_s
		
		# Creating enrty in the award type linking table
		OfferingAwardType.create(:offering_id => offering.id, :award_type_id =>  award_info.award_type_id)
		
		# Fgures out when to use 0, 5, or 20 as the max score 
		# Add in the Offering Review Criterion
		max_score = 0
		unless award_info.award_type_id == 1 # There is no max score for leadership awards so it is kept at 0
			if appl.YEAR.to_i > 2004 
				max_score = 20
			else
				# max_score = 5
			end
		end
		
		if appl.YEAR.to_i > 2004 
			OfferingReviewCriterion.create(:offering_id => offering.id, :title => "Total", :max_score => max_score)
		end
		
		# Create Application Review Decision Types
		decision_types = Hash["Yes, Interview" => YES_INTERVIEW_ID, "Yes" => YES_ID, "No" => NO_ID]
		decision_types.each do |decision_type, application_status_type_id|
			appl_review_decision_type = ApplicationReviewDecisionType.new
			appl_review_decision_type.offering_id = offering.id
			appl_review_decision_type.title = decision_type
			appl_review_decision_type.application_status_type_id = application_status_type_id
			if decision_type == "No"
				appl_review_decision_type.yes_option = 0
			else
				appl_review_decision_type.yes_option = 1
			end
			appl_review_decision_type.save!
		end
		# Create Offering Statuses
		offering_statuses = Hash["Awarded" => AWARDED_ID, "Not Awarded After Interview" => NOT_INTERVIEW_ID, "Not Awarded" => NOT_AWARDED_ID]
		offering_statuses.each do |offering_status, application_status_type_id|
			OfferingStatus.create(:offering_id => offering.id, :public_title => offering_status, :application_status_type_id => application_status_type_id)
		end
		
		# Add in the open_date and and the deadline
		offering.open_date = quarter.first_day
		offering.deadline = quarter.first_day + 3.months
#		puts "            Offering open: #{offering.open_date} close: #{offering.deadline}"
		
		# Save the offering
		offering.save! 
		
		return offering
		
	end
	
	# Creates a new Application For Offering from the passed offering, student, and original application
	def create_new_application_for_offering(offering, student, appl)
		appl_for_offering = ApplicationForOffering.new
		appl_for_offering.offering_id = offering.id
		appl_for_offering.person_id = student.id
		appl_for_offering.project_title = appl.PROJECT_TITLE
		if appl.PROJECT_DESCRIPTION.nil?
			appl_for_offering.project_description = appl.PROJECT_TITLE
		else
			appl_for_offering.project_description = appl.PROJECT_DESCRIPTION
		end
		appl_for_offering.hours_per_week = appl.HOURS
		appl_for_offering.special_notes = appl.COMMENT
		appl_for_offering.attended_info_session = (appl.InfoSession ? appl.InfoSession.abs : nil)
#		puts "          App for offering - offering id: #{appl_for_offering.offering_id.to_s} from student id: #{appl_for_offering.person_id.to_s}"
		
		# Add in the how did you find out text
		hear_string = []
		if appl.Find_out_email != 0
			hear_string << " Found out by Email"
		end
		if appl.Find_out_advisor_staff != 0
			hear_string << " Found out from Advisor Staff"
		end
		if appl.Find_out_faculty != 0
			hear_string << " Found out from Faculty"
		end
		if appl.Find_out_otherstudents != 0
			hear_string << " Found out from Other Students"
		end
		if appl.Find_out_web != 0
			hear_string << " Found out from the Web"
		end
		if appl.Find_out_other != nil
			hear_string << appl.Find_out_other.to_s
		end
		appl_for_offering.how_did_you_hear = hear_string.join("; ")
#		puts "            Heard from: " + appl_for_offering.how_did_you_hear
		
		appl_for_offering.save! # Save the application
		
		# Add in application_awards entries
		quarters_req = [appl.Q1_REQ, appl.Q2_REQ, appl.Q3_REQ]
		quarters_req.each do |quarter_req|
			unless quarter_req.nil?
				clean_quarter = quarter_req.downcase.gsub(/\s/,'') # Removes any spaces
				if clean_quarter =~ /^[asw][ipu][0-9][0-9]$/
					# Change the year to the full year
					year_abbr = clean_quarter[2,2]
					year = case year_abbr.to_i
						when 0..10 then "20" + year_abbr
						else "19" + year_abbr
					end
					# Figure out the quarter code
					quarter = case clean_quarter[0,2]
						when "wi" then 1
						when "sp" then 2
						when "su" then 3
						else 4
					end
					quarter_id = Quarter.find_easily(quarter,year).id
#					puts "            Quarter requested: #{quarter.to_s} - #{year.to_s} - Quarter ID: #{quarter_id} "
					
					appl_award = ApplicationAward.new
					appl_award.application_for_offering_id = appl_for_offering.id
					appl_award.requested_quarter_id = quarter_id
					appl_award.amount_requested_notes = "This quarter should not have an amount. The total requested is in the last record."
					appl_award.amount_awarded_notes = "On file with the Dean's Office"
					appl_award.amount_approved_notes = "On file with the Dean's Office"
					appl_award.amount_disbersed_notes = "On file with the Jodene"
					appl_award.save!
				end
			end
		end
		unless appl.AMOUNT_REQ.nil?
			# Make a NOTE about what this is doing
			# Puts in the amount Requested into the first Application Award entry or makes one if no quarters requested was listed
			appl_award = ApplicationAward.find(:first, :conditions => {:application_for_offering_id => appl_for_offering.id});
			unless appl_award.nil?
				appl_award.amount_requested = appl.AMOUNT_REQ.to_i
				appl_award.amount_requested_notes = "This is the total amount requested over all quarters."
#				puts "            Appended amount requested: #{appl_award.amount_requested}"
			else
				appl_award = ApplicationAward.new
				appl_award.application_for_offering_id = appl_for_offering.id
				appl_award.requested_quarter_id = offering.quarter_offered_id
				appl_award.amount_requested = appl.AMOUNT_REQ.to_i
				appl_award.amount_requested_notes = "This is the total amount requested, the quarter is the same as the offering becuase there was no requested quarter information."
#				puts "            Created amount requested: #{appl_award.amount_requested}"
				appl_award.amount_awarded_notes = "On file with the Dean's Office"
				appl_award.amount_approved_notes = "On file with the Dean's Office"
				appl_award.amount_disbersed_notes = "On file with the Jodene"
			end
			appl_award.save!
		end
		
		# !!!!!!!!!!!!!!!! Incomplete or Late needs to be handled here !!!!!!!!!!!!!!!!
		
		# Add in note about the number of prior quarters spent researching
		if appl.QUARTER_OF_RESEARCH.to_i > 0
			appl_for_offering.notes << Note.create(:note => "Number of quarters of research prior to this application: #{appl.QUARTER_OF_RESEARCH.to_s}",:creator_name => "Migration Controller")
		end
		
		return appl_for_offering
		
	end
	
	# Adds a mentor to the passed application
	def add_mentor(appl_for_offering , mentor_info)
		# Get the person record for the reviewer
		find_info = {:firstname => mentor_info.FirstName, :lastname => mentor_info.LastName, :email => mentor_info.EmailAddress, :address1 => mentor_info.Address, :city => mentor_info.City, :state => mentor_info.State, :zip => mentor_info.PostalCode, :salutation => " "}
		mentor = Person.find_or_create_by_best_guess(find_info)
		
		#mentor =  Student.find_by_student_no("0528239") # Use my own record to test
		
		tempMentor = ApplicationMentor.new
		tempMentor.application_for_offering_id = appl_for_offering .id
		tempMentor.person_id = mentor.id
		tempMentor.firstname = mentor.firstname
		tempMentor.lastname = mentor.lastname
		tempMentor.email = mentor.email
		
		tempMentor.save!
#		puts "            Mentor #{mentor.firstname} #{mentor.lastname} Added"
	end
	
	# Adds a reviewer to the offering and the application
	def add_reviewer(appl_for_offering , reviewer_info, offering_id, reviewer_or_mentor, award_type_letter, year)
		# Get the person record for the reviewer
		find_info = {:firstname => reviewer_info.FirstName, :lastname => reviewer_info.LastName, :email => reviewer_info.EmailAddress, :address1 => reviewer_info.Address, :city => reviewer_info.City, :state => reviewer_info.State, :zip => reviewer_info.PostalCode, :salutation => " "}
		reviewer = Person.find_or_create_by_best_guess(find_info)
		
		committee_id = award_type_letter == "R" ? MGE_RES_REV_COMM : OLD_MGE_REV_COMM
		
		#reviewer = Student.find_by_student_no("0528239") # Use my own record to test
		
		# Adds the person as a comittee member if they are not already in it
		comm_member = CommitteeMember.find(:first, :conditions => {:person_id => reviewer.id, :committee_id => committee_id})
		if comm_member.nil?
			comm_member = CommitteeMember.new
			comm_member.person_id = reviewer.id
			comm_member.committee_id = committee_id
			comm_member.committee_member_type_id = case reviewer_or_mentor.Status_Key
				when 3 then 2 # specialist reviewer
				else  1 # general reviewer / feedback contact
			end
			comm_member.skip_person_validations = true;
			comm_member.save!
#			puts "            New Committee Member"
		else
			comm_member.skip_person_validations = true;
#			puts "            Already Committee Member"
		end
		
		# Adds the person as a application reviewer if they are not already on it
		appl_reviewer = ApplicationReviewer.find(:first, :conditions => {:committee_member_id => comm_member.id, :application_for_offering_id => appl_for_offering.id})
		if appl_reviewer.nil?
			appl_reviewer = ApplicationReviewer.new
			appl_reviewer.committee_member_id = comm_member.id
			appl_reviewer.application_for_offering_id = appl_for_offering.id
			appl_reviewer.finalized = true
			appl_reviewer.save!
			appl_reviewer.create_scores
#			puts "            New App Reviewer"
		end
		# Adds the additional comment of feedback person to reviewers that also were one
		if reviewer_or_mentor.Status_Key == 4
				appl_reviewer.comments = "Feedback Person"
				appl_reviewer.save!
#				puts "            Feedback Person"
		end
		
#		puts "            App Reviewer app for offering id: #{appl_reviewer.application_for_offering_id.to_s}"
		
		# make the score entry (there should only ever be one)
		
		if year > 2004
			if appl_reviewer.scores.count == 1
				unless appl_reviewer.scores[0].score.to_i >= reviewer_or_mentor.Rating_Key.to_i
					score_to_change = appl_reviewer.scores[0]
					score_to_change.score = reviewer_or_mentor.Rating_Key
					score_to_change.save!
#					puts "            Reviewer Score: #{score_to_change.score}"
				else
#					puts "            Reviewer Score: Kept the pervious due to duplicate person"
				end
			else
#				puts "            BAD: It made #{appl_reviewer.scores.count.to_s} score entries instead of just 1"
			end
		end 
		appl_reviewer.save! # Save the application reviewer entry
		
	end
	
	# Based off of if they interviewed or not
	# Handle the entries of the final decisions
	# Create application_statuses entry here can be; not awarded (NOT_AWARDED_ID), not awarded after interview (NOT_INTERVIEW_ID) and awarded (AWARDED_ID) 
	# Also set the application status to yes or no
	def set_decisions(appl,  offering, appl_for_offering)
		
		review_decisions = offering.application_review_decision_types
		if appl.Interview.abs == 1
			appl_for_offering.application_review_decision_type_id = review_decisions.find(:first, :conditions => {:title => "Yes, Interview"}).id
			if offering.uses_interviews != 1
				offering.uses_interviews = 1
				check_prior_appls = offering.application_for_offerings
				check_prior_appls.each do |prior_appl|
					if prior_appl.id != appl_for_offering.id && prior_appl.application_review_decision_type_id == review_decisions.find(:first, :conditions => {:title => "Yes"}).id
						prior_appl.application_interview_decision_type_id = 1
						prior_appl.interview_committee_notes	= "The Access database didn't say that they got interviewed but for them to show up as awarded they need to be tagged as interviewed."
						prior_appl.save!
					end
				end
			end
			offering.save!
			if appl.RECEIVED.downcase.gsub(/\s/,'') == "yes" # Clean the string just to be safe
				appl_for_offering.application_interview_decision_type_id = 1
				appl_for_offering.application_statuses << ApplicationStatus.create(:application_status_type_id => AWARDED_ID)
#				puts "            Interviewed and Recieved"
			else
				appl_for_offering.application_interview_decision_type_id = 2
				appl_for_offering.application_statuses << ApplicationStatus.create(:application_status_type_id => NOT_INTERVIEW_ID)
#				puts "            Interviewed and Not Recieved"
			end
		elsif (offering.uses_interviews == 1 && appl.RECEIVED.downcase.gsub(/\s/,'') == "yes") 
			# Will set the person to yes and add interview flag for case where interview was not specified but they got it in an offering that has interviews
			appl_for_offering.application_review_decision_type_id = review_decisions.find(:first, :conditions => {:title => "Yes"}).id
			appl_for_offering.application_interview_decision_type_id = 1
			appl_for_offering.interview_committee_notes	= "The Access database didn't say that they got interviewed but for them to show up as awarded they need to be tagged as interviewed."
			appl_for_offering.application_statuses << ApplicationStatus.create(:application_status_type_id => AWARDED_ID)
		else
			if appl.RECEIVED.downcase.gsub(/\s/,'') == "yes" 
				appl_for_offering.application_review_decision_type_id = review_decisions.find(:first, :conditions => {:title => "Yes"}).id
				appl_for_offering.application_statuses << ApplicationStatus.create(:application_status_type_id => AWARDED_ID)
#				puts "            Recieved"
			else
				appl_for_offering.application_review_decision_type_id = review_decisions.find(:first, :conditions => {:title => "No"}).id
				appl_for_offering.application_statuses << ApplicationStatus.create(:application_status_type_id => NOT_AWARDED_ID)
#				puts "            Not Recieved"
			end
		end

		appl_for_offering.current_application_status_id = appl_for_offering.application_statuses.last.id
#		puts "            App Status ID = #{appl_for_offering.current_application_status_id}"
		
		return appl_for_offering
		
	end
	
end



