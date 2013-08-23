require 'csv'

desc "Import OMSFA's scholarships to EXPO"
task :import_omsfa_scholarships => :environment do  
  puts "Loaded #{RAILS_ENV} environment."
  
  lineno = 0
  
  print "Parsing CSV file...."
  file_path = "tmp/Scholarships.csv" #$stdin.gets.strip
  puts "(file path: #{file_path})\n\n"    
  
  scholarship_file = CSV.open(file_path, 'r', ?,, ?\r)
  #puts "scholarship_file : #{scholarship_file.inspect}"

  UNIT_ID = 7
  
  scholarship_file.each do |row|
    lineno += 1
    next if lineno == 1

    offering_name  = row[0].strip unless row[0].blank?
    year_offered   = row[1].strip unless row[1].blank?
    status_types   = row[2].strip.split(",") unless row[2].blank?
    student_no     = row[4].strip unless row[4].blank? # it could be uw netid
    email          = row[5].try(:strip) # it could be nil
    
    unless offering_name
      puts "No offering info: row #{lineno}"
    else      
      print "Fetching or creating offerings..."
      offering = Offering.find_or_create_by_name_and_unit_id_and_year_offered(offering_name, UNIT_ID, year_offered)
      offering.ask_for_mentor_title = true; offering.save; offering.reload
      offering_page = OfferingPage.find_or_create_by_offering_id_and_title(offering.id, 'Additional Information')
      offering_question = OfferingQuestion.find_or_create_by_offering_page_id_and_question_and_display_as_and_dynamic_answer(offering_page.id, 'Alternative email', 'short_response', 1)   
      # ["uw_nominee","national_finalist","national_honorable_mention","national_scholar"].each |status|
      #   offering_status = offering.statuses.find_or_create_by_application_status_type_id(ApplicationStatusType.find_by_name(status).id)
      #   offering_status.update_attributes(:public_title => status.gsub!(/_/, ' ').try(:titleize),
      #                                     :disallow_user_edits => 1,
      #                                     :disallow_all_edits => 1,
      #                                     :allow_application_edits => 0)
      # end
            
      print "=> #{offering.title}, #{offering.id}\n"
      print "Adding student and application info..."
      unless student_no
        puts "No UW NetId or student number: row #{lineno}"
      else          
          student = Student.find_by_anything(student_no).first
          app = ApplicationForOffering.find_or_create_by_person_id_and_offering_id(student.id, offering.id)
          
          app.set_answer(offering_question.id, email) if app.answers.blank?
          application_page = app.pages.find_by_offering_page_id(offering_page)
          application_page.started = true; application_page.complete = true          
          application_page.save;application_page.reload
          app.reload
          print " => App ID = #{app.id}\n"          
          unless status_types.blank?
            status_types.each do |status|
               s = OfferingStatus.find_or_create_by_offering_id_and_application_status_type_id(offering.id, ApplicationStatusType.find_by_name(status).id)
               app.set_status(status,false) # set up application statuses
               s.update_attributes(:public_title => status.gsub!(/_/, ' ').try(:titleize),
                                   :disallow_user_edits => 1,
                                   :disallow_all_edits => 1,
                                   :allow_application_edits => 0)
               s.save
            end
          end                    
                          
      end # end if student_no.blank?
      
      puts "Adding mentors information..."
      
      # check if includes mentors (3~8 mentors in most of cases) 
      (1..8).map{|r| r*5+1 }.each do |mentor_email_row|
        if row[mentor_email_row] && row[mentor_email_row].include?('@')
           is_uw_mentor = ["uw.edu","u.washington.edu"].include?(row[mentor_email_row].strip.split("@").second)
           expo_person  = Person.find_by_best_guess(:email => row[mentor_email_row].strip)

          if is_uw_mentor || expo_person
             if is_uw_mentor
               print " (uw mentor) "
               mentor_netid = row[mentor_email_row].strip.split("@").first
               mentor_person = User.find_by_login_and_identity_type(mentor_netid).try(:person)
             elsif expo_person
               print " (expo person) "
               mentor_person = expo_person
             end
             unless mentor_person.nil?
               mentor = ApplicationMentor.find_or_create_by_application_for_offering_id_and_person_id(app.id, mentor_person.id)
               mentor.update_attributes(:email => mentor_person.email || row[mentor_email_row].strip,
                                        :firstname => mentor_person.firstname || row[mentor_email_row + 1].strip , 
                                        :lastname => mentor_person.lastname || row[mentor_email_row + 2].strip,                                          
                                        :title => row[mentor_email_row + 3].strip)
               mentor.save
             end
          end
          
          if mentor.nil? 
             print " (non-uw or no-person) "
             mentor = ApplicationMentor.find_or_create_by_application_for_offering_id_and_email(app.id, row[mentor_email_row].strip)             
             mentor.update_attributes(:email     => row[mentor_email_row].strip,
                                      :firstname => row[mentor_email_row + 1].strip,
                                      :lastname  => row[mentor_email_row + 2].strip,                                      
                                      :title     => row[mentor_email_row + 3].strip + ", " +row[mentor_email_row + 4].strip)
             mentor.save                                              
          end
          
          print "=> (#{mentor.info_detail_line}, #{mentor.id}) \n"
        end
                
      end                  
      
    end #end if offering_name.blank?

  end
  puts "\nDone."      
end