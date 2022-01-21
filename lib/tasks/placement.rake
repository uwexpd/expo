require 'csv'

desc "Importing file for service learning placements permutation"

task :placements_permutation => :environment do
    print "Parsing CSV file...."
    file_path = "tmp/Wi22 HSF Script.csv"
    print "(file path: #{file_path})\n"

    import_file = CSV.open(file_path, 'r', ?,, ?\r)
    # puts "import_file : #{import_file.inspect}"

    puts "opened file..."

    lineno = 0
    placements = {}
    choice1_group = {}
    choice2_group = {}
    choice3_group = {}
    not_placed = []

    import_file.each do |col|
    	# puts "reading file: row => #{lineno}"
	    lineno += 1
	    next if lineno == 1 # skip title	      
		
	    fullname       = col[0].strip unless col[0].blank?
	    student_number = col[1].strip unless col[1].blank?
	    choice1  	   = col[2].strip unless col[2].blank?
	    choice2        = col[3].strip unless col[3].blank?
	    choice3        = col[4].strip unless col[4].blank?
	    # choice4        = col[5].strip unless col[5].blank?

		# puts "Row #{lineno}: #{fullname}, #{student_number}, #{choice1}, #{choice2}, #{choice3}"
	    
	    # Store as a hash for their 3 choices {key:values}
	    choice1_group[student_number] = ''
	    choice2_group[student_number] = ''
	    choice3_group[student_number] = ''

	    unless fullname.nil? || choice1.nil?	    
    		choice1_group[student_number] = choice1_group[student_number] << choice1 	    
    		choice2_group[student_number] = choice2_group[student_number] << choice2    	
    		choice3_group[student_number] = choice3_group[student_number] << choice3    	
	    end	    
	end
	# Remove nil value
	choice1_group = choice1_group.delete_if {|k,v| k.nil?}
	choice2_group = choice2_group.delete_if {|k,v| k.nil?}
	choice3_group = choice3_group.delete_if {|k,v| k.nil?}
	# puts "Choice1 Group: #{choice1_group.inspect}"
	# puts "Choice2 Group: #{choice2_group.inspect}"
	# puts "Choice3 Group: #{choice3_group.inspect}"
		
	#counts = Hash.new 0
    #choice1_group.each { |name, choice| counts[choice] += 1}
    #puts counts.inspect
    #{"Cerebro Cleanup Crew"=>7, "The Flash Photographer"=>1, "Atlantis Caretaker"=>3, "WW Social Media Manager"=>2, "Tony Stark's Apprentice"=>6, "Dr. Manhattan's Conceptual Advocate"=>1}

	#TODO load postions slots from file    
  #   positions = 
  #   {  
  #   	"Bailey-Boushay House- Front Desk Greeter" => 1,
		# "Bailey-Boushay House- Volunteer Program Assistant" => 4,
		# "Bloodworks NW- Blood Donor Recruiter" => 5,
		# "Boys and Girls Club of North Seattle- Afterschool Tutor and Mentor" => 6,
		# "Center for Human Services- After-school Program Tutors-Mentors" => 4,
		# "Chinese Information and Service Center- After-school Tutor for Chinese & Vietnamese ELL Students" => 9,
		# "East African Community Services- After School Tutor and Mentor" => 5,
		# "Hall Health Center- Improving Access to Sexual Health Care on Campus Team" => 3,
		# "Hall Health Center- UW Student Mental Health Task Force Support Team" => 4,
		# "Mary's Place- Volunteer Opportunities at Mary’s Place" => 4,
		# "Operation Nightwatch Seattle- Direct services intern/volunteer homeless dispatch center" => 4,
		# "Pike Market Senior Center and Food Bank- Discovering Pike Place Market Through a Public Health Lens" => 4,
		# "ROOTS Young Adult Shelter- Evening Shelter Volunteer" => 8,
		# "ROOTS Young Adult Shelter- Morning Shelter Volunteer" => 5,
		# "ROOTS Young Adult Shelter- Overnight Volunteer" => 4,
		# "UW Farm- UW Farm Intern" => 4,
		# "United Way of King County Tax Campaign- 2020 Census and Benefits Navigator" => 30
  #   }

	positions = 
    {
		"Bloodworks NW Blood Donor Engagement, Education and Sustainability Researcher (Remote)" => 2,
		"Bloodworks NW Blood Donor Health Education and Recruitment Planning (Remote or Hybrid)" => 2,
		"Food Lifeline Shop the Dock Ambassador (In Person/Onsite) (Interview Required)" => 5,
		"HealthPoint Quality Improvement Assistant 40-80 hour position Bothell Location (Remote) (Interview Required)" => 2,
		"Latino Educational Training Institute LatinX COVID-19 Community Health Educator (Remote)" => 3,		
		"Neighborhood House Creating Digital Health Education for Children, Teachers, and Caregivers (Remote) (Working w/Minors)" => 8,
		"Neighborhood House Health Educator: Skill Share Instructor for Youth (Remote) (Working with Minors)" => 8,
		"North Sound Accountable Communities for Health COVID-19 Response Intern (In Person/Onsite)" => 2,
		"Providence Regional Medical Center Community Health Education Program Support (Hybrid)" => 2,
		"Rainier Valley Community Clinic ARNP Visit Types: Social Media Content and Education (Remote)" => 1,
		"Rainier Valley Community Clinic Literature Review: Impact of Early Intervention on School Readiness (Remote)" => 4,
		"Rainier Valley Community Clinic Needs Assessment: Pregnancy and Parenting During High School and Physical and Emotional Healthcare Access in King County (Remote)" => 2,
		"Snohomish Health District Medical Reserve Corp Volunteer (In Person/Onsite) (Working w/Minors)" => 10,
		"Snohomish Health District Public Health Communication Intern (Remote)" => 8,
		"UWB SNHS Social Media Communications Assistant Mental Health Matters (90% Remote) (Interview Required)" => 1,
		"UWB SNHS Communication and Social Media Assistant (Remote)" => 1,
		"Village Reach Global Health Advocacy and Communications Intern (Hybrid)" => 1,
		"WA West African Center Pillar Youth, Adult, and Senior Programs Assistance (In Person/Onsite/Hybrid) (Working w/Minors)" => 8
    }    
    puts "RUN Permutation"
    #Run permutation 
    while choice1_group.size > 0
    	# puts "debug: Choice1 Group: #{choice1_group.inspect}"
	    # Random pick 
	    placement = choice1_group.to_a.choice #["Brooke Kirk", "Cerebro Cleanup Crew"]

	    # remove random picked student from choice groups
	    choice1_group.delete(placement[0])
	    # puts "debug: #{placement[0]} => #{placement[1]} (#{positions[placement[1]]})"

	    # check if number of position is enough
	    if positions[placement[1]] > 0
	    	# place into the position
	    	placements[placement[0]] = placement[1]
	    	# Minus number of position
	    	positions[placement[1]] = positions[placement[1]] - 1
			# remove placed student from rest of choice groups
	    	choice2_group.delete(placement[0])
	    	choice3_group.delete(placement[0])
	    end	    
	end    
	# puts "#{placements.size} Placements : #{placements.inspect}"
	# puts "Postions : #{positions.inspect}"
	# puts "#{choice1_group.size} Choice1 Group Left : #{choice1_group.inspect}"
	# puts "#{choice2_group.size} Choice2 Group : #{choice2_group.inspect}"

	while choice2_group.size > 0
	    placement = choice2_group.to_a.choice
	    choice2_group.delete(placement[0])
	    #puts "debug: #{placement[0]} => #{placement[1]} (#{positions[placement[1]]})"

	    if positions[placement[1]] > 0	    	
	    	placements[placement[0]] = placement[1]	    	
	    	positions[placement[1]] = positions[placement[1]] - 1	    	
	    	choice3_group.delete(placement[0])
	    end
	end

	while choice3_group.size > 0
		placement = choice3_group.to_a.choice
		choice3_group.delete(placement[0])

	    if positions[placement[1]] > 0	    	
	    	placements[placement[0]] = placement[1]	    	
	    	positions[placement[1]] = positions[placement[1]] - 1	    
	    else 
	    	not_placed << placement[0]
	    end
	end
    puts "Result :"
	puts "#{placements.size} Placements : #{placements.inspect}"
	puts "Postions left detail: #{positions.inspect}"
	puts "#{not_placed.size} students not placed: #{not_placed.inspect}"

end