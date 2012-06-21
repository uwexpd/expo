namespace :symposium do
  task :auto_assign_poster_sessions => :environment do
    puts "Loaded #{RAILS_ENV} environment."
    STDOUT.sync = true
  
    # Fetch offering
    print "What is the Offering ID? "
    offering = Offering.find $stdin.gets.strip
    puts "#{offering.title}"
    
    # Get variables
    for session in offering.sessions
      puts "   #{session.id.to_s.ljust(10)} #{session.title}"
    end
    print "\nWhat is the OfferingSession id for poster session 1? "
    poster1 = offering.sessions.find $stdin.gets.strip
    puts poster1.title
    
    print "\nWhat is the OfferingSession id for poster session 2? "
    poster2 = offering.sessions.find $stdin.gets.strip
    puts poster2.title
    
    print "\nWhat is the OfferingSession id for poster session 3? "
    poster3 = offering.sessions.find $stdin.gets.strip
    puts poster3.title
    
    # Get all mentor department names
    puts "\nLoading applications..."    
    apps = offering.applications_with_status("submitted")    
    puts "\n#{apps.size} applications loaded."      
            
    apps = apps.select{|a| a.application_type.try(:title) == 'Poster Presentation' && a.location_section_id.nil? }
    #mcnair_id = offering.other_award_types.find_by_award_type_id(AwardType.find_by_title("McNair").id).id
    #apps = apps.reject{|a| a.other_awards.find_by_offering_other_award_type_id(mcnair_id)}
    puts "#{apps.size} poster applications have not yet been assigned."
    
    depts = {}
    for app in apps
      dept = app.primary_mentor.academic_department
      depts[dept] = depts[dept].nil? ? [app] : depts[dept] << app
    end
    depts = depts.sort_by{|k,v| k.to_s}
    puts "#{depts.size} departments sorted."
    
    location_section_id = nil
    # For each department, ask how to split up the apps
    for dept, apps in depts
      puts "\n#{dept} (#{apps.size} apps): "
      if dept.blank?
        app_no_dept ||= []
        apps.each{|app| app_no_dept << app.id }
        puts "\n No academic department apps: [#{app_no_dept.join(', ')}]"
      end
      print "    Assign to Poster Session 1: [enter => skip] [0 => countinue assigning] "
      poster1_count = $stdin.gets.strip
      if poster1_count.blank?
        puts "     (skipping)"
      else
        poster1_count = poster1_count.to_i
        if poster1_count > 0
          print "    Location (#{offering.location_sections.collect{|l| l.id.to_s+'='+l.title}.join(', ')}): "
          location_section_id = $stdin.gets.strip.to_i
          apps[0..(poster1_count-1)].each do |app|
            app.update_attribute(:offering_session_id, poster1.id)
            app.update_attribute(:location_section_id, location_section_id)
            print "      #{app.id.to_s.ljust(6)} #{app.fullname.ljust(40)}"
            print " #{app.offering_session.title.ljust(20)} #{app.location_section.title}\n"
          end
        end
        
        print "    Assign to Poster Session 2: "
        poster2_count = $stdin.gets.strip.to_i
        if poster2_count > 0
          print "    Location (#{offering.location_sections.collect{|l| l.id.to_s+'='+l.title}.join(', ')}) [#{location_section_id}]: "
          location_section_id_poster2 = $stdin.gets.strip.to_i
          apps[poster1_count..(poster2_count)].each do |app|
            app.update_attribute(:offering_session_id, poster2.id)
            app.update_attribute(:location_section_id, location_section_id_poster2)
            print "      #{app.id.to_s.ljust(6)} #{app.fullname.ljust(40)}"
            print " #{app.offering_session.title.ljust(20)} #{app.location_section.title}\n"
          end          
        end
                        
        poster3_count = apps.size - poster1_count - poster2_count
        if poster3_count > 0
          print "    Assign to Poster Session 3: #{poster3_count}\n"
          print "    Location (#{offering.location_sections.collect{|l| l.id.to_s+'='+l.title}.join(', ')}) [#{location_section_id}][#{location_section_id_poster2}]: "
          location_section_id_poster3 = $stdin.gets.strip.to_i
          #location_section_id_poster3 = input.blank? ? location_section_id : input.to_i
          apps[poster2_count..(apps.size)].each do |app|
            app.update_attribute(:offering_session_id, poster3.id)
            app.update_attribute(:location_section_id, location_section_id_poster3)
            print "      #{app.id.to_s.ljust(6)} #{app.fullname.ljust(40)}"
            print " #{app.offering_session.title.ljust(20)} #{app.location_section.title}\n"
          end
        end
      end
    end
    
  end

  task :fix_department_names => :environment do
    puts "Loaded #{RAILS_ENV} environment."
    STDOUT.sync = true
  
    # Fetch offering
    print "What is the Offering ID? "
    offering = Offering.find $stdin.gets.strip
    puts "#{offering.title}"
    
    # Get all mentor department names
    puts "Loading applications..."
    apps = offering.applications_with_status("submitted")
    puts "\n#{apps.size} applications loaded."
    depts = {}
    for app in apps
      for mentor in app.mentors
        dept = mentor.department
        depts[dept] = depts[dept].nil? ? [mentor] : depts[dept] << mentor
      end
    end
    depts = depts.sort_by{|k,v| k.to_s}
    puts "#{depts.size} departments sorted."

    # For each department, ask if we need to change the title
    # TODO New_title should be updated into +mentor_department+ in ApplicationForOffering instead of person's department @12-20-2011_Josh
    for dept, mentors in depts
      print "\n#{dept} (#{mentors.size} mentors). Rename to [#{dept}]: "
      new_title = $stdin.gets.strip
      unless new_title.blank?
        for mentor in mentors
          print mentor.person.update_attribute(:other_department, new_title) ? " #{mentor.application_for_offering.id}  #{mentor.fullname} => #{new_title}\n" : "   ERROR"
        #print mentor.application_for_offering.update_attribute(:mentor_department, new_title) ? " #{mentor.application_for_offering.id}  #{mentor.fullname} => #{new_title}\n" : "   ERROR"
        end
      end
    end
    
  end
  
  task :fix_organization_names => :environment do
    puts "Loaded #{RAILS_ENV} environment."
    STDOUT.sync = true
    print "What is the Offering ID? "
    offering = Offering.find $stdin.gets.strip
    puts "#{offering.title}"
    people = offering.application_for_offerings.with_status(:confirmed).collect(&:mentors).flatten.collect(&:person).flatten.compact
    puts "#{people.size} people."
    
    while true
      print "\nFind: "
      find = $stdin.gets.strip
      Process.exit if find.blank?
      people_to_edit = people.select{|p| p.organization == find}
      # people_to_edit.each{|p| print "\n    " + p.id.to_s.ljust(10) + p.organization }
      print "    -> #{people_to_edit.size} found"
      unless people_to_edit.empty?
        print "\nReplace with [type 'nil' to remove]: "
        replace = $stdin.gets.strip
        unless replace.blank?
          print "    Replacing: "
          replace = nil if replace == 'nil'
          people_to_edit.each{|p| p.update_attribute(:organization, replace); print "."}
        end
        print "\n"
      end
    end
  end

  task :import_department_data => :environment do
    puts "Loaded #{RAILS_ENV} environment."
    STDOUT.sync = true
    puts "CSV should have these fields: dept_code, fixed_name, chair_name, chair_title, chair_email"
    print "Input file path of CSV file: "
    file_path = $stdin.gets.strip
    puts file_path

    print "\nShould I update department names (or just the chair info)? [Yn] "
    update_names = $stdin.gets.strip == "Y"

    lineno = 0

    puts "Parsing CSV file "
    file = CSV.open(file_path, 'r', ?,, ?\r)
    file.each do |p|
      lineno += 1
      next if lineno == 1
      dept_code = p[0]

      dhash = {}
      dhash[:fixed_name]  = p[1].strip if !p[1].blank? && update_names
      dhash[:chair_name]  = p[2].strip unless p[2].blank?
      dhash[:chair_title] = p[3].strip unless p[3].blank?
      dhash[:chair_email] = p[4].strip.gsub(/\312/, "") unless p[4].blank?

      unless dhash.empty?
        dept = DepartmentExtra.find_or_create_by_dept_code(dept_code)
        puts dept_code.to_s.ljust(5) + dept.name
        pp(dhash) if dept.update_attributes(dhash)
      end
      print "\n"
    end

    puts "\nDone."
  end

  # task :add_scholarships_to_mgh_awardees => :environment do
  #     puts "Loaded #{RAILS_ENV} environment."
  # 
  #     # Fetch offering
  #     print "What is the Offering ID? "
  #     offering = Offering.find $stdin.gets.strip
  #     puts "#{offering.title}"    
  #     puts "Awardees number: #{offering.awardees.size}"
  #       
  #     for awardee in offering.awardees
  #       
  #       
  #       
  #       
  #     end    
  #     
  #   end  

end
