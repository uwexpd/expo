require 'csv'

=begin rdoc
These rake tasks handle the initial import tasks required for the annual accountability process.

1. load_courses_from_file: Expects a tab-separated file of courses. Adds them in as ActivityCourse records.
   All activity types are put into a single file.
2. load_projects_from_file: Expects a CSV file of individual activity. Adds them in as ActivityCourse records.
   Only one activity type can be processed at a time, so one CSV file should contain public service data and 
   another should have research data.
3. add_source_departments: Goes through all of the Activity records and tries to convert department names
   into department ID's to link them to real academic departments. You can then provide alternatives for names
   that can't be found. Note that this will only find _academic_ departments listed in the SDB, so some will just
   use the name only (e.g., "Pipeline Project").
4. add_reporting_departments: Similar to add_source_departments but only operates on ActivityCourse objects with
   the +reporting_department_name+ attribute set. Instead of converting the +department_id+ field, it updates the
   +reporting_department_id+ field.
   
After all of these processes have been completed, you're ready to run an actual AccountabilityReport, which will
accumulate and process student records from all of the associated activities.
=end
namespace :accountability do
  
  desc "Triggers a regeneration of an accountability report (Specify REPORT_ID in ENV)"
  task :regenerate_report => :environment do
    puts "Loaded #{RAILS_ENV} environment."
    report_id = ENV['REPORT_ID']
    ar = AccountabilityReport.find(report_id)
    return false if ar.nil?
    ar.final_statistics(true)
  end
  
  task :fetch_registrants => :environment do
    puts "Loaded #{RAILS_ENV} environment."
    STDOUT.sync = true
  
    # Fetch offering
    print "Input file path of tab-separated file:"
    file_path = $stdin.gets.strip
    file = File.read(file_path)
    puts "Read #{file.each_line("\r").count} lines"
    
    course_hashes = []
    courses = []
    errors = []
    results = []
    students = {}
    credits = 0.0
    
    print "Parsing file "
    file.each_line("\r") do |l|
      c = l.split("\t")
      chash = {:dept => c[4], :course_no => c[5], :section_id => c[6]}
      course_hashes << chash.merge({:quarter_abbrev=>"SUM2008"}) && print(".") if c[9] =="x"
      course_hashes << chash.merge({:quarter_abbrev=>"AUT2008"}) && print(".") if c[10]=="x"
      course_hashes << chash.merge({:quarter_abbrev=>"WIN2009"}) && print(".") if c[11]=="x"
      course_hashes << chash.merge({:quarter_abbrev=>"SPR2009"}) && print(".") if c[12]=="x"
    end
    
    puts " #{course_hashes.size} courses"
    
    puts "\nFinding Course objects in SDB..."
    course_hashes.each do |c|
      q = Quarter.find_by_abbrev(c[:quarter_abbrev])
      begin
        course = Course.find(q.year, q.quarter_code_id, 0, c[:course_no], c[:dept], c[:section_id])
        courses << course
        # puts "    #{course.short_title} (#{Quarter.find_easily(course.ts_quarter, course.ts_year).to_param})"
      rescue ActiveRecord::RecordNotFound
        errors << c
        puts "    ERROR: #{c.inspect}"
      end
    end
    
    puts "Found #{courses.size} courses and #{errors.size} errors."
    
    puts "\nFinding registrants for each course..."
    courses.each do |c|
      course_title = "#{c.short_title} (#{Quarter.find_easily(c.ts_quarter, c.ts_year).to_param})"
      c.registrants.each do |r|
        result = []
        result << r.student_record.student_no
        result << r.student_record.fullname
        result << r.student_record.class_standing_description
        result << c.dept_abbrev
        result << c.course_no
        result << c.section_id
        result << Quarter.find_easily(c.ts_quarter, c.ts_year).to_param
        result << r.credits.to_s
        results << result
        if students[r.system_key]
          students[r.system_key][:courses] << course_title
        else
          students[r.system_key] = { :record => r.student_record, :courses => [course_title] }
        end
        credits += r.credits
      end
      puts "    #{course_title}".ljust(30) + c.registrants_count.to_s
    end
      
    puts "Found a total of #{results.size} students (#{students.size} unique) for a total of #{credits.to_s} credits."
   
    print "Output file path for all registrant records:"
    file_path = $stdin.gets.strip
    results_string = results.collect{|r| r.join("|")}.join("\r")
    File.open(file_path, 'w') {|f| f.write(results_string)}
    
    puts "\nResults can be found in #{file_path}"

    print "Output file path for unique students:"
    file_path = $stdin.gets.strip
    results_string = ""
    students.each do |system_key, s|
      results_string << [s[:record].student_no, s[:record].fullname, s[:courses].count.to_s, s[:courses].join(", ")].join("|")
      results_string << "\r"
    end
    File.open(file_path, 'w') {|f| f.write(results_string)}
    puts "\nResults can be found in #{file_path}"
  end
  
  desc "Loads a file of accountability courses into the Activity model."
  task :load_courses_from_file => :environment do
    puts "Loaded #{RAILS_ENV} environment."
    STDOUT.sync = true
  
    # Get file
    unless ENV['SOURCE_FILE']
      print "Input file path of tab-separated file: "
      file_path = $stdin.gets.strip
    else
      file_path = ENV['SOURCE_FILE']
    end
    
    course_hashes = []
    bad_course_hashes = []
    courses = []
    errors = []
    results = []
    activities = []
    lineno = 0
    quarters = %w(SUM2008 AUT2008 WIN2009 SPR2009)
    
    puts "Parsing file "
    puts "Using these quarters: #{quarters.join(", ")}"
    file = File.read(file_path)
    file.each("\r") do |l|
      lineno += 1
      next if lineno == 1
      c = l.strip.split("\t")
      next if c.size <= 1
      chash = { :preparer_uw_netid => c[5],
                :reporting_department_name => c[3],
                :course_branch => (c[2].blank? ? 0 : c[2].to_i),
                :dept_abbrev => c[6].to_s.upcase, 
                :course_no => c[7].to_i, 
                :section_id => c[8], 
                :title => c[10],
                :notes => c[16],
                :hours_per_week => c[17].to_f }
      type_title = c[15].to_s.strip
      if type_title == "Public Service"
        activity_type = "S"
      elsif type_title == "Research"
        activity_type = "R"
      else
        activity_type = "."
        puts "\nERR   Invalid activity type specified on line #{lineno}: #{type_title}"
      end
      chash[:activity_type_id] = ActivityType.find_by_abbreviation(activity_type).id
      q = quarters.collect{ |abbrev| Quarter.find_by_abbrev(abbrev).id }
      course_hashes << chash.merge({:quarter_id=>q[0]}) && print(activity_type) if c[11].to_s.strip.downcase=="x"
      course_hashes << chash.merge({:quarter_id=>q[1]}) && print(activity_type) if c[12].to_s.strip.downcase=="x"
      course_hashes << chash.merge({:quarter_id=>q[2]}) && print(activity_type) if c[13].to_s.strip.downcase=="x"
      course_hashes << chash.merge({:quarter_id=>q[3]}) && print(activity_type) if c[14].to_s.strip.downcase=="x"
    end
    
    puts "\nFound #{course_hashes.size} course(s). Finding section_ids for courses that need them..."
    course_hashes.each_with_index do |chash, i|
      if chash[:section_id].blank?
        print "DEL   #{pretty_print_hash(chash).ljust(30, ".")}"
        bad_course_hashes << chash
        quarter = Quarter.find(chash[:quarter_id])
        curric = Curriculum.valid_for(quarter).find_by_curric_abbr(chash[:dept_abbrev])
        if curric.nil?
          puts " Cannot find curriculum for #{chash[:dept_abbrev]} in #{quarter.abbrev}"
          next
        end
        section_ids = curric.section_ids(chash[:course_no], quarter)
        new_chashes = []
        for section_id in section_ids
          new_chash = {}
          new_chash = chash.merge(:section_id => section_id)
          course_hashes << new_chash
          new_chashes << new_chash
        end
        if new_chashes.empty?
          puts " No replacements found"
        else
          puts " Replace with section(s) #{new_chashes.collect{|c| c[:section_id]}.join(", ")}"
        end
      else
        # puts "OK    #{pretty_print_hash(chash)}"
      end
    end
    
    puts "\nDeleting #{bad_course_hashes.size} bad courses from #{course_hashes.size} current items..."
    course_hashes.delete_if{|x| bad_course_hashes.include?(x)}
    
    puts "Left with #{course_hashes.size} course(s). Checking for valid courses..."
    course_hashes.each do |chash|
      a = ActivityCourse.new(chash)
      if a.valid?
        activities << a 
        print "."
      else
        puts "\nERR   #{pretty_print_hash(chash).ljust(30, ".")} Course is invalid"
      end
    end
    
    print "\nReady to import #{activities.size} activity record(s). Continue? [y/n] "
    decision = $stdin.gets.strip
    if decision.downcase == "y"
      activities.each do |a|
        puts "IMPORT #{a.dept_abbrev} #{a.course_no} #{a.section_id}: #{a.save}" if a.valid?
      end
    end
    
    puts "Done."
  end

  desc "Loads a file of accountability individual involvement into the Activity model."
  task :load_projects_from_file => :environment do
    puts "Loaded #{RAILS_ENV} environment."
    STDOUT.sync = true
  
    # Get file
    unless ENV['SOURCE_FILE']
      print "Input file path of CSV file: "
      file_path = $stdin.gets.strip
    else
      file_path = ENV['SOURCE_FILE']
    end

    # Get activity_type
    unless ENV['ACTIVITY_TYPE']
      print "What activity type (R or S): "
      activity_type_abbrev = $stdin.gets.strip
    else
      activity_type_abbrev = ENV['ACTIVITY_TYPE']
    end
    activity_type = ActivityType.find_by_abbreviation(activity_type_abbrev)
    puts "Activity Type: #{activity_type.title}"

    activities = []
    project_hashes = {}
    lineno = 0
    quarters = %w(SUM2008 AUT2008 WIN2009 SPR2009)
    puts "Using these quarters: #{quarters.join(", ")}"
    quarter_columns = [8,9,10,11]
    
    puts "Parsing CSV file "
    file = CSV.open(file_path, 'r', ?,, ?\r)
    file.each do |p|
      lineno += 1
      next if lineno == 1
      # p = l.rstrip.split("\t")
      # next if p.size <= 1
      student_search = p[7]
      # print student_search.ljust(15, ".")
      system_key = nil
      sr = nil
      if student_search.blank?
        sr = StudentRecord.find_by_name(p[6], 2)
        if sr.size > 1
          puts " ERR   #{lineno.to_s.ljust(5)} Multiple students found for \"#{student_search}\""
          next
        else
          sr = sr.first
        end
      elsif student_search.to_i.zero?
        sr = StudentRecord.find_by_uw_netid(student_search)
      else
        sr = StudentRecord.find_by_student_no(student_search)
      end
      if sr.nil?
        new_search = student_search[1..6] if !student_search.nil? && student_search.length == 7 && student_search[0]==79
        sr = StudentRecord.find_by_student_no(new_search)
      end
      if sr.nil?
        puts " ERR   #{lineno.to_s.ljust(5)} Cannot find student record for \"#{student_search}\""
        next
      else
        puts " OK    #{lineno.to_s.ljust(5)} requested #{p[6].ljust(35)} search:     #{student_search}"
        puts "             found     #{sr.fullname.to_s.ljust(35)} student_no: #{sr.student_no}   netid: #{sr.uw_netid}  system_key: #{sr.system_key}"
      end
      system_key = sr.system_key
      phash = { :preparer_uw_netid => p[3],
                :faculty_name => p[4],
                :faculty_uw_netid => p[5],
                :system_key => system_key,
                :activity_type_id => activity_type.id,
                :department_name => p[1],
                :title => p[12]
              }
      hours_are_total = p[13].to_s.strip.blank? ? false : true
      quarter_hashes = []
      quarters.each_with_index do |quarter, i|
        hours = p[quarter_columns[i]].to_s.strip.to_f
        unless hours.zero?
          qhash = hours_are_total ? { :number_of_hours => hours } : { :hours_per_week => hours }
          qhash[:quarter_id] = Quarter.find_by_abbrev(quarter).id
          qhash[:quarter_abbrev] = quarter
          quarter_hashes << qhash
        end
      end
      project_hashes[lineno] = { :activity => phash, :quarters => quarter_hashes }
    end
    
    print "\nReady to import #{project_hashes.size} activity record(s). Continue? [y/n] "
    decision = $stdin.gets.strip
    if decision.downcase == "y"
      project_hashes.sort.each do |k,project|
        ap = ActivityProject.new(project[:activity])
        ap.save
        if ap.valid?
          print "IMPORT #{k.to_s.ljust(5)} #{"ActivityProject #{ap.id}".ljust(30, ".")} "
          for quarter_hash in project[:quarters]
            print "#{quarter_hash.delete(:quarter_abbrev)}: "
            q = ap.quarters.create(quarter_hash)
            print (q.valid? ? (q.read_attribute(:number_of_hours).nil? ? "#{q.hours_per_week}w" : "#{q.number_of_hours}t") : "ERR").ljust(10)
          end
          print "\n"
        else
          puts "ERR    #{k.to_s.ljust(5)} [#{ap.errors.full_messages.join(", ")}]"
        end
      end
    end
    
    puts "Done."
  end

  desc "Tries to add the department ID to all Activity records."
  task :add_source_departments => :environment do
    STDOUT.sync = true
    @errors = []
    until @errors.nil?
      puts "\nFinding departments..."
      for activity in Activity.find(:all, :conditions => { :department_id => nil }, :order => "dept_abbrev DESC, department_name")
        name = activity.department_name
        use_abbrev = false
        if name.nil?
          name = activity.dept_abbrev
          use_abbrev = true
        end
        if use_abbrev
          dept = Department.find_by_dept_abbr(name)
          dept = Department.find_by_dept_abbr(name.gsub(" ", "")) if dept.nil?
          dept = Department.find(:first, :conditions => "REPLACE(dept_abbr,' ','') = '#{name}'") if dept.nil?
          dept = Curriculum.find_by_curric_abbr(name).try(:department) if dept.nil?
        else
          dept = Department.find_by_dept_full_nm(name)
          dept = Department.find_by_dept_full_nm(name.gsub("and", "&")) if dept.nil?
        end
        if dept
          print activity.id.to_s.ljust(6)
          print "#{name[0..57].ljust(60, ".")}"
          puts " found #{dept.dept_full_nm}"
          activity.update_attributes({:department_name => nil, :department_id => dept.id})
        else
          @errors << name
        end
      end
      if @errors.empty?
        @errors = nil
      else
        print "\nCouldn't find these departments:\n  "
        puts @errors.uniq.join("\n  ")

        print "\nSuggest new names? [y/n] "
        suggest = $stdin.gets.strip
        if suggest == 'y'
          for error in @errors.uniq.compact
            print "Try something new for #{error} (#{@errors.select{|n| n == error}.size.to_s} records): "
            new_name = $stdin.gets.strip
            if new_name.blank?
              puts "  No records updated."
            else
              to_update = Activity.find_all_by_department_name(error)
              to_update.each{|a| a.update_attribute(:department_name, new_name)}
              puts "  Updated #{to_update.size.to_s} record(s)."
            end
          end
          @errors = []
        else
          puts "OK."
          break
        end
      end
    end
  end

  desc "Tries to add the reporting department ID to all Activity records."
  task :add_reporting_departments => :environment do
    STDOUT.sync = true
    @errors = []
    until @errors.nil?
      puts "\nFinding reporting_departments..."
      activities = Activity.find(:all, 
                      :conditions => "reporting_department_id IS NULL AND reporting_department_name IS NOT NULL", 
                      :order => "reporting_department_name")
      for activity in activities
        name = activity.reporting_department_name
        dept = Department.find_by_dept_full_nm_and_dept_branch(name, activity.course_branch)
        dept = Department.find_by_dept_full_nm_and_dept_branch(name.gsub("and", "&"), activity.course_branch) if dept.nil?
        if dept
          print activity.id.to_s.ljust(6)
          print "#{name[0..57].ljust(60, ".")}"
          puts " found #{dept.dept_full_nm}"
          activity.update_attributes({:reporting_department_name => nil, :reporting_department_id => dept.id})
        else
          @errors << name
        end
      end
      if @errors.empty?
        @errors = nil
      else
        print "\nCouldn't find these reporting_departments:\n  "
        puts @errors.uniq.join("\n  ")

        print "\nSuggest new names? [y/n] "
        suggest = $stdin.gets.strip
        if suggest == 'y'
          for error in @errors.uniq.compact
            print "Try something new for #{error} (#{@errors.select{|n| n == error}.size.to_s} records): "
            new_name = $stdin.gets.strip
            if new_name.blank?
              puts "  No records updated."
            else
              to_update = Activity.find_all_by_reporting_department_name(error)
              to_update.each{|a| a.update_attribute(:reporting_department_name, new_name)}
              puts "  Updated #{to_update.size.to_s} record(s)."
            end
          end
          @errors = []
        else
          puts "OK."
          break
        end
      end
    end
  end

  def pretty_print_hash(h, include_quarter = true, include_activity_type = true)
    t = "#{h[:dept_abbrev]} #{h[:course_no]} #{h[:section_id]}"
    t << " - #{Quarter.find(h[:quarter_id]).abbrev}" if include_quarter
    t << " [#{ActivityType.find(h[:activity_type_id]).abbreviation}]" if include_activity_type
    t
  end
  
end



