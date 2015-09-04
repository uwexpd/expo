require 'csv'

desc "Import OMSFA's scholarships to EXPO"
task :import_omsfa_scholarships => :environment do  
  puts "Loaded #{RAILS_ENV} environment."
  
  lineno = 0
  
  print "Parsing CSV file...."
  file_path = "tmp/2014-15-OMSFA-upload-data.csv" #$stdin.gets.strip
  puts "(file path: #{file_path})\n\n"
  
  scholarship_file = CSV.open(file_path, 'r', ?,, ?\r)
  #puts "scholarship_file : #{scholarship_file.inspect}"

  UNIT_ID = 7
  
  scholarship_file.each do |row|
    lineno += 1
    next if lineno == 1

    offering_name     = row[0].strip unless row[0].blank?
    year_offered      = row[1].strip unless row[1].blank?
    quarter_offered   = row[2].strip.downcase unless row[2].blank?
    status_types      = row[3].strip.split(",") unless row[3].blank?
    student_no        = row[4].strip unless row[3].blank? # it could be uw netid
    alt_email         = row[5].try(:strip)
    current_address   = row[6].try(:strip)
    current_city      = row[7].try(:strip)
    current_state     = row[8].try(:strip)
    current_zip       = row[9].try(:strip)
    current_phone     = row[10].try(:strip)
    permanent_address = row[11].try(:strip)
    permanent_city    = row[12].try(:strip)
    permanent_state   = row[13].try(:strip)
    permanent_zip     = row[14].try(:strip)
    permanent_phone   = row[15].try(:strip)
    parent_firstname  = row[16].try(:strip)
    parent_lastname   = row[17].try(:strip)
    parent_email      = row[18].try(:strip)
    parent2_firstname = row[19].try(:strip)
    parent2_lastname  = row[20].try(:strip)
    parent2_email     = row[21].try(:strip)
                                
    unless offering_name
      puts "No offering info: row #{lineno}"
    else
      puts "-------------------------------------------------------------------------------------------------------------"      
      print "Fetching or creating offerings..."
      # convert quarter code
      quarter_offered_id = nil
      unless quarter_offered.blank?
        quarter_code_id = case quarter_offered
          when 'winter' then 1
          when 'spring' then 2
          when 'summer' then 3
          when 'fall'   then 4
        end
        quarter_offered_id = Quarter.find_easily(quarter_code_id, year_offered).id
      end
            
      offering = Offering.find_or_create_by_name_and_unit_id_and_year_offered_and_quarter_offered_id(offering_name, UNIT_ID, year_offered, quarter_offered_id)
      offering.ask_for_mentor_title = true; offering.save; offering.reload  
                   
      print "=> #{offering.title}, #{offering.id}\n"
      print "Adding student and application info..."
      unless student_no
        puts "No UW NetId or student number: row #{lineno}"
      else          
          student_person = Student.find_by_anything(student_no).first          
          # Adding omsfa student information
          print "O"
          p = OmsfaStudentInfo.find_or_create_by_person_id(student_person.id)
          p.update_attributes(:alt_email => alt_email,
                              :current_address => current_address,
                              :current_city => current_city,
                              :current_state => current_state,
                              :current_zip => current_zip,
                              :current_phone => current_phone,
                              :permanent_address => permanent_address,
                              :permanent_city => permanent_city,
                              :permanent_state => permanent_state,
                              :permanent_zip => permanent_zip,
                              :permanent_phone => permanent_phone,
                              :parent_firstname => parent_firstname,
                              :parent_lastname => parent_lastname,
                              :parent_email => parent_email,
                              :parent2_firstname => parent2_firstname,
                              :parent2_lastname => parent2_lastname,
                              :parent2_email => parent2_email)          
          
          # Adding application info
          print "A"          
          app = ApplicationForOffering.find_or_create_by_person_id_and_offering_id(student_person.id, offering.id)                    
          # app.set_answer(offering_question.id, alt_email) if app.answers.blank?
          # application_page = app.pages.find_by_offering_page_id(offering_page)
          #           application_page.started = true
          #           e; application_page.complete = true          
          #           application_page.save;application_page.reload
          # app.reload
          print " => App ID = #{app.id}\n"
          unless status_types.blank?
            status_types.each do |status|
               s = OfferingStatus.find_or_create_by_offering_id_and_application_status_type_id(offering.id, ApplicationStatusType.find_by_name(status).id)
               app.set_status(status,false) # set up application statuses
               s.update_attributes(:public_title => status.gsub!(/_/, ' ').try(:titleize),
                                   :disallow_user_edits => 1,
                                   :disallow_all_edits => 1,
                                   :allow_application_edits => 0)
            end
          end
                          
      end # end if student_no.blank?
      
      puts "Adding mentors information..."
      
      # check if includes mentors (3~8 mentors in most of cases), mentor info starts from 22th column
      (1..8).map{|r| r*5+17 }.each do |mentor_email_row|
      #puts "#{row[mentor_email_row]}"
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
                                        :firstname => mentor_person.firstname || row[mentor_email_row + 1].try(:strip), 
                                        :lastname => mentor_person.lastname || row[mentor_email_row + 2].try(:strip),                                          
                                        :title => row[mentor_email_row + 3].try(:strip))                                   
               mentor_person.update_attribute(:other_department, mentor_person.department_name || row[mentor_email_row + 4].try(:strip))
             end
          end
          
          if mentor.nil?
             print " (no-person-record) "
             mentor = ApplicationMentor.find_or_create_by_application_for_offering_id_and_email(app.id, row[mentor_email_row].strip)
             mentor.update_attributes(:email     => row[mentor_email_row].strip,
                                      :firstname => row[mentor_email_row + 1].try(:strip),
                                      :lastname  => row[mentor_email_row + 2].try(:strip),
                                      :title     => row[mentor_email_row + 3].strip + ", " +row[mentor_email_row + 4].try(:strip))
          end
          
          print "=> (#{mentor.info_detail_line}, #{mentor.id}) \n" if mentor
        end
                
      end                  
      
    end #end if offering_name.blank?

  end
  puts "\n ---------- Done! ------------ \n"      
end