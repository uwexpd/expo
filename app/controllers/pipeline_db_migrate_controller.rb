class PipelineDbMigrateController  < ActionController::Base
  require 'csv'
=begin  
        School
          school_name_value
          phone_value

          Organization Contacts
            OrganizationId => organization_id
            PersonId => person_id

            Person
              contact_value => split and place
              contact_position_value
              contact_phone_value
              contact_email_value
              contact_two_value => split and place
              contact_two_position_value
              contact_two_phone_value
              contact_two_email_value

        Location
          school_name_value => title
          address_value => address_line_1
          city_value => address_city
          "WA" => address_state
          zip_value => address_zip
          locaiton_value => neighborhood
          bus_directions_value => bus_directions
          OrganizationId => organization_id

        Organization Quarter

        Pipeline Positon
          school_description_value => description

          Pipeline Position Subjects
            foreign_language_check
            foreign_language_value => split make for each
            math_check
            science_check
            social_studies_check
            language_arts_check
            art_check
            history_check
            ell_check
            special_ed_check

          Pipeline Position Tutoring Types
            small_group_check
            one_on_one_check
            class_aid_check
            after_school_check
            other_tutoring_formats_value

          Pipeline Position Grade Levels
            grade_k_2_check
            grade_3_5_check

          Pipeline Position Times
            day_time_needed_value

          Supervisor Person
=end

  def run_migration(loop_start = 0, loop_end = 100)
  PipelinePosition.transaction do
    # set school types
    elementary_school = SchoolType.find(:first,:conditions=>{:name=>"Elementary School"})
    elementary_school = elementary_school.nil? ? SchoolType.create(:name=>"Elementary School") : elementary_school
    k_through_eight_school = SchoolType.find(:first,:conditions=>{:name=>"K-8 School"})
    k_through_eight_school = k_through_eight_school.nil? ? SchoolType.create(:name=>"K-8 School") : k_through_eight_school
    middle_school = SchoolType.find(:first,:conditions=>{:name=>"Middle School"})
    middle_school = middle_school.nil? ? SchoolType.create(:name=>"Middle School") : middle_school
    high_school = SchoolType.find(:first,:conditions=>{:name=>"High School"})
    high_school = high_school.nil? ? SchoolType.create(:name=>"High School") : high_school
    
    # set grade levels
    grade_level_k_2 = PipelinePositionsGradeLevel.find(:first,:conditions=>{:name=>"K-2"})
    grade_level_k_2 = grade_level_k_2.nil? ? PipelinePositionsGradeLevel.create(:name=>"K-2") : grade_level_k_2
    grade_level_3_5 = PipelinePositionsGradeLevel.find(:first,:conditions=>{:name=>"3-5"})
    grade_level_3_5 = grade_level_3_5.nil? ? PipelinePositionsGradeLevel.create(:name=>"3-5") : grade_level_3_5
    grade_level_6_8 = PipelinePositionsGradeLevel.find(:first,:conditions=>{:name=>"6-8"})
    grade_level_6_8 = grade_level_6_8.nil? ? PipelinePositionsGradeLevel.create(:name=>"6-8") : grade_level_6_8
    grade_level_9_12 = PipelinePositionsGradeLevel.find(:first,:conditions=>{:name=>"9-12"})
    grade_level_9_12 = grade_level_9_12.nil? ? PipelinePositionsGradeLevel.create(:name=>"9-12") : grade_level_9_12
    
    # set tutoring formats
    one_on_one_tutoring = PipelinePositionsTutoringType.find(:first,:conditions=>{:name=>"One on one tutoring"})
    one_on_one_tutoring = one_on_one_tutoring.nil? ? PipelinePositionsTutoringType.create(:name=>"One on one tutoring") : one_on_one_tutoring
    small_group_tutoring = PipelinePositionsTutoringType.find(:first,:conditions=>{:name=>"Small group tutoring"})
    small_group_tutoring = small_group_tutoring.nil? ? PipelinePositionsTutoringType.create(:name=>"Small group tutoring") : small_group_tutoring
    class_aid = PipelinePositionsTutoringType.find(:first,:conditions=>{:name=>"Class aid"})
    class_aid = class_aid.nil? ? PipelinePositionsTutoringType.create(:name=>"Class aid") : class_aid
    after_school_tutoring = PipelinePositionsTutoringType.find(:first,:conditions=>{:name=>"After school tutoring"})
    after_school_tutoring = after_school_tutoring.nil? ? PipelinePositionsTutoringType.create(:name=>"After school tutoring") : after_school_tutoring
    
    # get current quarter
    current_quarter = Quarter.current_quarter
    
    # get the pipeline unit record
    unit = Unit.find_by_abbreviation "pipeline"
    
    (loop_start..loop_end).each do |i|
      @saved_info = nil
      if File.exist?( "files/pipeline_files/"+i.to_s+".yaml" )
	      @saved_info = YAML::load( File.read( "files/pipeline_files/"+i.to_s+".yaml" ) )
        
        # set the city to seattle if needed
        @saved_info["city_value"] = "Seattle" if @saved_info["city_value"] == ""
        
        # make subjects array
        subjects = []
        subjects << "Math" unless @saved_info["math_check"].nil?
        subjects << "Science" unless @saved_info["science_check"].nil?
        subjects << "Language Arts" unless @saved_info["language_arts_check"].nil?
        subjects << "Social Studies" unless @saved_info["social_studies_check"].nil?
        subjects << "Art" unless @saved_info["art_check"].nil?
        subjects << "History" unless @saved_info["history_check"].nil?
        subjects << "English Language Learners" unless @saved_info["ell_check"].nil?
        subjects << "Special Education" unless @saved_info["special_ed_check"].nil?
        unless @saved_info["foreign_language_value"].empty?
          languages = @saved_info["foreign_language_value"].split(/,\s?/)
          languages.each do |language|
            subjects << language.titleize
          end
        end
        
        # figure out the school type
        school_type = nil
        school_type = @saved_info["grade_k_2_check"].nil? ? school_type : elementary_school
        school_type = @saved_info["grade_3_5_check"].nil? ? school_type : elementary_school
        school_type = @saved_info["grade_6_8_check"].nil? ? school_type : 
                                    school_type.nil? ? middle_school : k_through_eight_school
        school_type = @saved_info["grade_9_12_check"].nil? ? school_type : high_school
        
        name_without_school = @saved_info["school_name_value"].gsub("School","").strip
        name_with_school = name_without_school+" School"
        @school = Organization.find(:first,:conditions=>{:name=>name_with_school.strip})
        if @school.nil?
          @school = Organization.find(:first,:conditions=>{:name=>name_without_school})
        end
        @location = nil
        @contact_one = nil
        if @school.nil?
          @school = School.new(:name=>@saved_info["school_name_value"].empty? ? nil : @saved_info["school_name_value"].strip, 
                               :mailing_line_1=>@saved_info["address_value"].empty? ? nil : @saved_info["address_value"].strip,
                               :mailing_city=>@saved_info["city_value"].empty? ? nil : @saved_info["city_value"].strip,
                               :mailing_state=>"Washington",
                               :mailing_zip=>@saved_info["zip_value"].empty? ? nil : @saved_info["zip_value"].strip,
                               :main_phone=>@saved_info["phone_value"].empty? ? nil : @saved_info["phone_value"].strip, 
                               :mission_statement=>@saved_info["school_description_value"].empty? ? nil : @saved_info["school_description_value"],
                               :school_type_id=>school_type.id,
                               :does_pipeline=>true,
                               :target_school=>@saved_info["target_school_check"].nil? ? nil : true)
          @school.save!
          unless @saved_info["address_value"].empty?
            @location = Location.new(:title=>@saved_info["school_name_value"].empty? ? nil : @saved_info["school_name_value"].strip,
                                     :address_line_1=>@saved_info["address_value"].empty? ? nil : @saved_info["address_value"].strip,
                                     :address_city=>@saved_info["city_value"].empty? ? nil : @saved_info["city_value"].strip,
                                     :address_state=>"Washington",
                                     :address_zip=>@saved_info["zip_value"].empty? ? nil : @saved_info["zip_value"].strip,
                                     :neighborhood=>@saved_info["location_value"].empty? ? nil : @saved_info["location_value"].strip,
                                     :bus_directions=>@saved_info["bus_directions_value"].empty? ? nil : @saved_info["bus_directions_value"].strip,
                                     :organization_id=>@school.id)
            @location.save!
          end
          
          unless @saved_info["contact_value"].empty?
            name = @saved_info["contact_value"].split(" ")
            
            @person = Person.find_or_create_by_best_guess(:firstname=>name[0],
                                    :lastname=>name[1],
                                    :phone=>@saved_info["contact_phone_value"].empty? ? nil : @saved_info["contact_phone_value"].strip,
                                    :email=>@saved_info["contact_email_value"].empty? ? nil : @saved_info["contact_email_value"].strip)
            @contact_one = OrganizationContact.create(:person_id => @person.id,
                                                      :organization_id => @school.id,
                                                      :pipeline_contact => true)
            @contact_one.unit_ids = [unit.id]
          end
          @contact_two = nil
          unless @saved_info["contact_two_value"].empty?
            name = @saved_info["contact_two_value"].split(" ")
            @person = Person.find_or_create_by_best_guess(:firstname=>name[0],
                                    :lastname=>name[1],
                                    :phone=>@saved_info["contact_two_phone_value"].empty? ? nil : @saved_info["contact_two_phone_value"].strip,
                                    :email=>@saved_info["contact_two_email_value"].empty? ? nil : @saved_info["contact_two_email_value"].strip)
            @contact_two = OrganizationContact.create(:person_id => @person.id,
                                                      :organization_id => @school.id,
                                                      :pipeline_contact => true)
            @contact_two.unit_ids = [unit.id]
          end
        else
          @school.update_attribute(:type,"School")
          @school.school_type_id = school_type.id
          @school.save!
          skip_contact = false
          unless @school.contacts.empty?
            @school.contacts.each do |contact|
              if contact.pipeline_contact
                skip_contact = true
              end
            end
          end
          unless skip_contact || @saved_info["contact_value"].empty?
            name = @saved_info["contact_value"].split(" ")

            @person = Person.find_or_create_by_best_guess(:firstname=>name[0],
                                    :lastname=>name[1],
                                    :phone=>@saved_info["contact_phone_value"].empty? ? nil : @saved_info["contact_phone_value"].strip,
                                    :email=>@saved_info["contact_email_value"].empty? ? nil : @saved_info["contact_email_value"].strip)
            @contact_one = OrganizationContact.create(:person_id => @person.id,
                                                      :organization_id => @school.id,
                                                      :pipeline_contact => true)
          end
          @location = nil
          if @school.locations.empty?
            unless @saved_info["address_value"].empty?
              @location = Location.new(:title=>@saved_info["school_name_value"].empty? ? nil : @saved_info["school_name_value"].strip,
                                       :address_line_1=>@saved_info["address_value"].empty? ? nil : @saved_info["address_value"].strip,
                                       :address_city=>@saved_info["city_value"].empty? ? nil : @saved_info["city_value"].strip,
                                       :address_state=>"WA",
                                       :address_zip=>@saved_info["zip_value"].empty? ? nil : @saved_info["zip_value"].strip,
                                       :neighborhood=>@saved_info["location_value"].empty? ? nil : @saved_info["location_value"].strip,
                                       :bus_directions=>@saved_info["bus_directions_value"].empty? ? nil : @saved_info["bus_directions_value"].strip,
                                       :organization_id=>@school.id)
              @location.save!
            end
          else
            @location = @school.locations.first
          end
          
        end
        
        @organization_quarter = OrganizationQuarter.find(:first,:conditions=>{:quarter_id=>current_quarter.id,
                                                                              :organization_id=>@school.id,
                                                                              :unit_id=>unit.id})
        if @organization_quarter.nil?
          @organization_quarter = OrganizationQuarter.create(:quarter_id=>current_quarter.id,
                                                             :organization_id=>@school.id,
                                                             :unit_id=>unit.id)
        end
        #position_title = @saved_info["school_name_value"]
        position_title = ""
        first = true
        last = false
        count = 1
        subjects.each do |subject|
          last = true if count == subjects.size
          list_mod = first ? " " : last ? " and " : ", " 
          position_title = position_title+list_mod+subject
          first = false
          count += 1
        end
        position_title = position_title+" Tutor"
        puts position_title
        @pipeline_position = PipelinePosition.new(:title=>position_title,
                                                  :organization_quarter_id=>@organization_quarter.id,
                                                  :location_id=>@location.nil? ? nil : @location.id,
                                                  :approved=>true,
                                                  :times_are_flexible=>true,
                                                  :supervisor=>@contact_one.nil? ? nil : @contact_one,
                                                  :description=>@saved_info["tutoring_opportunities_value"]+" \n"+
                                                                @saved_info["additional_tutoring_opportunities_value"])
        @pipeline_position.save!
        
        # find and create subjects
        subjects.each do |subject|
          added_subject = PipelinePositionsSubject.find(:first,:conditions=>{:name=>subject})
          added_subject = added_subject.nil? ? PipelinePositionsSubject.create(:name=>subject) : added_subject
          @pipeline_position.subjects << added_subject
        end
        
        # add in grades
        unless @saved_info["grade_k_2_check"].nil?
          @pipeline_position.grade_levels << grade_level_k_2
        end
        unless @saved_info["grade_3_5_check"].nil?
          @pipeline_position.grade_levels << grade_level_3_5
        end
        unless @saved_info["grade_6_8_check"].nil?
          @pipeline_position.grade_levels << grade_level_6_8
        end
        unless @saved_info["grade_9_12_check"].nil?
          @pipeline_position.grade_levels << grade_level_9_12
        end
        
        # add in tutoring type
        unless @saved_info["one_on_one_check"].nil?
          @pipeline_position.tutoring_types << one_on_one_tutoring
        end
        unless @saved_info["small_group_check"].nil?
          @pipeline_position.tutoring_types << small_group_tutoring
        end
        unless @saved_info["class_aid_check"].nil?
          @pipeline_position.tutoring_types << class_aid
        end
        unless @saved_info["after_school_check"].nil?
          @pipeline_position.tutoring_types << after_school_tutoring
        end
        
        # add in times
        # get days
        days_hash = {"m"=>:monday,"t"=>:tuesday,"w"=>:wednesday,"th"=>:thursday,"f"=>:friday}
        days_array = ["m","t","w","th","f"]
        times = @saved_info["day_time_needed_value"].split(/\n/)
        times.each do |time|
          unless time.empty?
            time_days = []
            days = time.split(" ")[0].downcase
            days.split("&").each do |day|
              span = day.split("-")
              if span.size == 1
                time_days << days_hash[span[0]]
              else
                first = false
                second = false
                days_array.each do |day_a|
                  if day_a == span[0]
                    first = true
                  end
                  if first && !second
                    time_days << days_hash[day_a]
                  end
                  if day_a == span[1]
                    second = true
                  end
                end
              end
            end
          
            # get times
            hours = time.downcase.scan(/(\d?\d):(\d\d).*?(\d?\d):(\d\d).*?(am|pm)/)[0]
            if hours[0].to_i < 6
              hours[0] = (hours[0].to_i + 12).to_s
            end
            if (hours[4] == "pm") && (hours[2].to_i != 12)
              hours[2] = (hours[2].to_i + 12).to_s
            end
           
            @pipline_positon_time = ServiceLearningPositionTime.new(:service_learning_position_id=>@pipeline_position.id,
                                                                    :start_time=>Time.parse(hours[0]+":"+hours[1]),
                                                                    :end_time=>Time.parse(hours[2]+":"+hours[3]))
            time_days.each do |time_day|
              @pipline_positon_time[time_day] = true
            end
          
            @pipline_positon_time.save
          end
        end
        
      end
    end
  end
  end
  
=begin
Create an Event and Event Time for the quarter
  - first see if one exists

Add student to the event if their background check and orientation time are nil
  - set orientation time
  - set background check
  - set pipeline student info
    = MIT
    = ELS Minor?
    = Recruitment
    
Keep the type of volunteer

Keep a list of the people that could not be found

=end
  def add_old_quarter_students(quarter = nil, file = nil)
    if quarter.nil? || quarter.class != Quarter
      puts "Pass a quarter and a file"
    else
      event_title = "Pipeline Orientations " + quarter.title
      event_type = EventType.find_by_title "Orientation"
      unit = Unit.find_by_abbreviation "pipeline"
      event = Event.find_or_create_by_title_and_event_type_id_and_unit_id(event_title, event_type.id, unit.id)
      #event.unit_id = unit.id
      #event.event_type_id = event_type.id
      #event.save!
      event.times << EventTime.new(:start_time => quarter.first_day)
      event.reload
      event_time = event.times.first
      
      Student.transaction do
        # turn csv into array of hashes
        student_file = CSV.open("files/pipeline_files/"+file,'r', ?,, ?\r)
        headers = student_file.shift.map {|i| i.to_s }
        string_data = student_file.map {|row| row.map {|cell| cell.to_s } }
        student_array = string_data.map {|row| Hash[*headers.zip(row).flatten] }
        student_array.pop # the last record is garbage
        
        # open the file that stores the skipped student names
        skipped_file = File.open("files/pipeline_files/skipped_students.txt", 'a')
        
        student_array.each do |student|
          # student["name"]
          # student["id"]
          # student["email"]
          # student["volunteer_type"]
          # student["recruitment"]
          # student["mit"]
          
          s_record = nil
          # search for the student by student number
          unless student["id"].empty?
            s_record = Student.find_by_student_no student["id"]
          end
          # if nothing was found or student["id"] is empty then look by email
          if s_record.nil?
            s_record = Student.find_by_uw_netid student["email"].split("@")[0]
          end
          
          if s_record.nil?
            # if the record was still not found then print the name to a text file
            skipped_file.puts student["name"]
          else
            # add the student to the event time 
            event_time.invite!(s_record, {:checkin_time => event_time.start_time})
            
            # set the pipeline vars in the student record
            if s_record.pipeline_orientation.nil? || (s_record.pipeline_orientation < event_time.start_time)
              s_record.pipeline_orientation = event_time.start_time
            end
            if s_record.pipeline_background_check.nil? || (s_record.pipeline_background_check < event_time.start_time)
              s_record.pipeline_background_check = event_time.start_time
            end
            s_record.save!
            s_record.reload
            
            if s_record.pipeline_student_info.nil?
              pipeline_student_info = PipelineStudentInfo.new(:how_did_you_hear => student["recruitment"], 
                                                              :fulfill_mit => (student["mit"].downcase == "yes"),
                                                              :person_id => s_record.id)
              # skip validations for the survey use .save_with_validation!(false)
              pipeline_student_info.save!
            end
            
          end
          
        end
        
        skipped_file.close
      end
    end
  end
  
end