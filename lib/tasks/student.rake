require 'csv'

desc "Import a csv file that includes students and run a search to see if the students are in specific courses for Todd Sperry/OMAD"
task :student_courses => :environment do  
  puts "Loaded #{RAILS_ENV} environment."
  STDOUT.sync = true
    
  # Fetch offering
  print "What is the Department ID/code? (E.g: math => 206, biol => 112, Q SCI = 750, ENGL = 136). Please enter: "
  department = Department.find $stdin.gets.strip
  puts "Department: #{department.name}"
  
  # Fetch quarter
  print "What is the quarter ID? Press enter/skip if current quarter. Please enter: "
  quarter_keyin = $stdin.gets.strip
  if quarter_keyin.blank? 
    quarter = Quarter.current_quarter 
  else
    quarter = Quarter.find(quarter_keyin)
  end  
  puts "Quarter: #{quarter.title}"
  
  # Fetch courses 
  math_courses = [111,120,124,125,126,300,301,307,308,309,324,326,327,328] 
  biol_courses = [118,180,200,220]
  qsci_courses = [291,292,381]
  engl_courses = [110,111,121,131,198,199,200,281]
  courses = []  
  dept_courses = []  
  
  #print "What are the courses no, such as 111,120,124(using commons to seperate). Please enter: "
  #$stdin.gets.split(",").each{|i| puts "#{i.to_i}" }
  #puts "#{courses_keyin}"
  
  dept_courses = case department.dept_code
  when 206 then math_courses
  when 112 then biol_courses
  when 750 then qsci_courses
  when 136 then engl_courses
  else
      puts "Can't find the department code."
  end    
    
  dept_courses.each do |course_no|
    Course.find_all_by_short_title(department.dept_abbr, course_no, quarter).each{|c| courses << c}
  end
  puts "#{courses.size} course(s): #{courses.collect(&:short_title).join(", ")}"
  
  print "Parsing CSV file...."
  #print "Input file path of CSV file: "
  file_path = "tmp/SSS_ID_SUM_2014.csv" #$stdin.gets.strip
  print "(file path: #{file_path})\n"
    
  # turn csv into array of hashes
  student_file = CSV.open(file_path, 'r', ?,, ?\r)  
  student_data = student_file.map{|row| row.map {|cell| cell.to_s } }
  puts "Total students number: #{student_data.size}"  
  puts "====================================================================================================================="
    
  for s in student_data
      enrolled_courses = []
      student = Student.find_by_student_no(s)
      courses.each{|c| enrolled_courses << c.short_title if c.enrolls?(student, :include_extra_enrollees=>false)}
      
      unless enrolled_courses.blank?              
        print "#{student.student_no.to_s.ljust(7)}    #{student.fullname.ljust(40)}       #{student.email.ljust(30)}      #{enrolled_courses} \n"
      end
  end  
      
end

desc "Get pipeline volunteers for accountability report 2011"
task :pipeline_volunteers => :environment do  
  puts "Loaded #{RAILS_ENV} environment."
  
  @quarters = Quarter.all(:conditions => {:id=>[16,17,18,19]})
  placement_students = []
  orientation_students = Student.find(:all, :conditions => ["pipeline_orientation > ?", Quarter.find(16).first_day])
  puts "orientation_students: #{orientation_students.size}"
  
  for q in @quarters
    q.service_learning_placements.select(&:filled?).select{|p|  p.unit_id == 4}.collect(&:person).each{|person| placement_students << person}
  end
  puts "placement_students: #{placement_students.size}"
    
  for student in orientation_students               
    unless placement_students.include?(student)
        print "#{student.student_no.to_s.ljust(7)}   #{student.fullname.ljust(40)}   #{student.pipeline_orientation}\n"
    end        
  end              
end

desc "Import a csv file that includes McNair scholars adn check if they are MGE scholars"
task :check_if_MGE_scholar=> :environment do
    puts "Loaded #{RAILS_ENV} environment."
    
    print "Parsing CSV file...."
    #print "Input file path of CSV file: "
    file_path = "tmp/McNair_Scholar.csv" #$stdin.gets.strip
    print "(file path: #{file_path})\n"

    # turn csv into array of hashes
    student_file = CSV.open(file_path, 'r', ?,, ?\r)  
    student_data = student_file.map{|row| row.map {|cell| cell.to_s } }
    puts "Total students number: #{student_data.size}"  
    puts "====================================================================================================================="
    
    mge_awardees = Population.find(257).object_ids[:Student].uniq.sort
    puts "Loaded All MGE uniqe awardees: #{mge_awardees.size}"
    
    for s in student_data
      student = Student.find_by_student_no(s)      
      if mge_awardees.include?(student.id)
        print "#{student.student_no.to_s.ljust(7)}    #{student.fullname.ljust(35)}       #{student.email.ljust(25)}  \n"
      end
            
    end    
    
end

desc "Get pipeline placements with 2 or 3 quarters in a row from Fall 2013 to Spring 2014"
task :pipeline_placements => :environment do  
  puts "Loaded #{RAILS_ENV} environment."

  placements = Quarter.find(220,221,222).collect(&:service_learning_placements).flatten.select(&:filled?).select{|p|p.unit_id == 4}  
  puts "placements: #{placements.size}"  
  students={}
  placements.each{|s| students[s.person_id] = (students[s.person_id].nil? ? [s.quarter_id] : students[s.person_id] << s.quarter_id )}

  puts "Student who tutored 3 academic quarters => #{students.select{|k,v| v.size==3}.size}"
  puts "Student who tutored Fall and Winter quarters => #{students.select{|k,v| v.size==2 && v[0]=="220" && v[1]="221"}.size}"
  puts "Student who tutored Winter and Spring quarters => #{students.select{|k,v| v.size==2 && v[0]=="221" && v[1]="222"}.size}"

end

desc "Get pipeline placements total number of credits that students have enrolled for acedemic year 2013"
task :inner_pipeline_credits => :environment do
  placements = Quarter.find(24,25,26,27).collect(&:service_learning_placements).flatten.select{|p| p.unit_id == 4 && p.filled? && p.allocated? && p.course.pipeline_student_type_id == 1}
  
  puts "Inner pipeline placements: #{placements.size}"
  
  total_credits = 0
  
  for p in placements    
    for c in p.course.courses            
      credits = StudentRecord.find(p.person.system_key).registrations.for(p.position.quarter).courses.fetch_course_credits(c)      
      total_credits += credits if credits      
    end        
  end
  
  puts "Total credits => #{total_credits}"
  
end


desc "Import a csv file wiht UW NetID and return their student numbers for Jumpstart"
task :student_number => :environment do
    print "Parsing CSV file...."    
    file_path = "tmp/Jumpstart.csv"
    print "(file path: #{file_path})\n"
    
    student_file = CSV.open(file_path, 'r', ?,, ?\r)  
    student_data = student_file.map{|row| row.map {|cell| cell.to_s } }
    puts "Total students number: #{student_data.size}"  
    puts "====================================================================================================================="

    for s in student_data      
      student = Student.find_by_uw_netid(s)
      print "#{student.student_no.to_s.ljust(7)}    #{student.fullname.ljust(35)}       #{student.email.ljust(25)}  \n" if student
    end
    
end

desc "Import a csv file wiht UW NetID and return their student number for pipeline Alternative Spring Break "
task :student_number_abs => :environment do
    print "Parsing CSV file...."    
    file_path = "tmp/pipeline_2014.csv"
    print "(file path: #{file_path})\n"
    
    student_file = CSV.open(file_path, 'r', ?,, ?\r)  
    student_data = student_file.map{|row| row.map {|cell| cell.to_s } }
    puts "Total students number: #{student_data.size}"  
    puts "====================================================================================================================="

    for s in student_data
      uwnetid = s.to_s.match(/^(\w+)(@.+)?$/).try(:[], 1) 
      student = Student.find_by_uw_netid(uwnetid)
      print "#{student.student_no.to_s.ljust(7)}    #{student.fullname.ljust(35)}       #{student.email.ljust(25)}  \n" if student
    end
    
end


desc "Import for migration of general study faculty data"
task :general_study_faculty => :environment do
    print "Parsing CSV file...."    
    file_path = "tmp/GENST_Faculty.csv"
    print "(file path: #{file_path})\n"
    
    lineno = 0
    
    faculty_file = CSV.open(file_path, 'r', ?,, ?\r)  
   
     puts "Start to add faculty information..."
     
    faculty_file.each do |row|
      lineno += 1    

      fullname     = row[0].strip unless row[0].blank?
      code         = row[1].strip unless row[1].blank?
      employee_id  = row[2].strip unless row[2].blank?
      uw_netid     = row[3].strip unless row[3].blank?

      # fullname     = row[0].blank? ? row[0] : row[0].strip 
      # code         = row[1].blank? ? row[1] : row[1].strip 
      # employee_id  = row[2].blank? ? row[2] : row[2].strip 
      # uw_netid     = row[3].blank? ? row[3] : row[3].strip
      
      unless fullname.blank?
        lastname  = fullname.split(",").first.try(:strip).try(:capitalize)
        firstname = fullname.split(",").second.try(:strip).try(:capitalize)
      end          

      faculty = GeneralStudyFaculty.find_or_create_by_code(code)
      faculty.update_attributes(:firstname => firstname,
                                :lastname => lastname,
                                :uw_netid => uw_netid,
                                :code => code,
                                :employee_id => employee_id,
                                :created_at => Time.now)
      faculty.save
    end
    
    puts "Updated #{lineno} General Study Fauclty"
    
end

desc "Test a course for negative string"
task :test_course => :environment do
      puts "test starts....."
      src = StudentRegistrationCourse.find_by_system_key(1788493)
      puts "#{src.inspect}"
      course = src.course
      puts "#{y course}"
end
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   