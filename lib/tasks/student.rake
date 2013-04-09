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
  math_courses = [98,111,120,124,125,126,300,307,308,309,324,327] 
  biol_courses = [118,180,200,220]
  qsci_courses = [291]
  engl_courses = [109,111,121,131,197,198,199,200,281]
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
  file_path = "tmp/SSS_ID_Fall_2012.csv" #$stdin.gets.strip
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

desc "Get pipeline placements with 2 or 3 quarters in a row from Fall 2011 to Spring 2012"
task :pipeline_placements => :environment do  
  puts "Loaded #{RAILS_ENV} environment."

  placements = Quarter.find(21,22,23).collect(&:service_learning_placements).flatten.select(&:filled?).select{|p|p.unit_id == 4}  
  puts "placements: #{placements.size}"  
  students={}
  placements.each{|s| students[s.person_id] = (students[s.person_id].nil? ? [s.quarter_id] : students[s.person_id] << s.quarter_id )}

  puts "#{students.select{|k,v| v.size==3}.size}"
  puts "#{students.select{|k,v| v.size==2 && v[0]=="21" && v[1]="22"}.size}"
  puts "#{students.select{|k,v| v.size==2 && v[0]=="22" && v[1]="23"}.size}"

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



