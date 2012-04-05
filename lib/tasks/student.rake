require 'csv'

desc "Get a csv file that includes 300+ students and run a search to see if the students are in specific courses"
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
  math_courses = [98,120,124,125,126,300,307,308,309,324,327,328] 
  biol_courses = [118,180,200,220]
  qsci_courses = [292]
  engl_courses = [110,111,121,131,198,200,281]
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
  file_path = "tmp/SSS_ID_Spring_2012.csv" #$stdin.gets.strip
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