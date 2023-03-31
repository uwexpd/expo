require 'csv'

desc "Importing file for service learning placements permutation"

task :placements_permutation => :environment do
    print "Parsing CSV file...."
    file_path = "tmp/Spr_HSF_placements.csv"
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
	positions = 
    {
		"Alyssa Burnett Adult Life Center Classroom Engagement Support (In Person/Onsite) (Interview Required)"=>5,
		"Bloodworks NW Occupational Safety & Health Intern (Hybrid)"=>2,
		"Communities of Color Coalition (C3) Community Engagement & Project Coordinator Assistant (Hybrid)"=> 2,
		"Everett Gospel Mission Community Engagement and Activity Assistant (In Person/Onsite) (Working w/Minors)"=>4,
		"Food Lifeline Shop the Dock Ambassador (In Person/Onsite) (Interview Required)"=>5,
		"Girls on the Run of Snohomish County Girls on the Run (GOTR) Coach (In person/Onsite) (Working w/Minors)"=>4,
		"HealthPoint Quality Improvement Assistant 40 to 80 hour position Bothell Location (Remote)"=>2,
		"Latino Educational Training Institute (LETI) Child Care Circle Coordinator (Remote)"=>1,
		"Latino Educational Training Institute (LETI) LatinX COVID-19 Community Health Educator (Remote)"=>1,
		"Mercy Housing Northwest Community Health Supporter (In person/Onsite)"=>2,
		"Mercy Housing Northwest Youth Program Intern Girls on the Run (In Person/Onsite) (w/Minors)"=>4,
		"Midwives Association of WA State Education & Promotion Administrative Coordinator (Remote)"=>2,
		"NAMI Eastside Mental Health Education and Support Program Assistant (Remote)"=>4,
		"Neighborhood House Creating Digital Health Education for Children, Teachers, and Caregivers (Remote) (Working w/Minors)"=>8,
		"Neighborhood House Health Educator: Skill Share Instructor for Youth (Remote) (Working w/Minors)"=>8,
		"North Sound Accountable Communities for Health Community Catalyst Intern (Majority Remote AND In Person/Onsite)"=>2,
		"Snohomish Health District Access to Baby and Child Dentistry Secondary Coordinators (Remote/Hybrid) (Working w/Minors)"=>2,
		"Tavon Learning Center Lifelong Learning Intern Health Studies (Hybrid)"=>2,
		"UW Bothell ARC Health and Wellness Resource Center (HAWRC) Fieldwork Project for Wellness Fest (Hybrid)"=>4,
		"UW Bothell School of Nursing and Health Studies Communication and Social Media Assistant (Remote)"=>1,
		"UW Pacific Northwest Agriculture Safety and Health (PNASH) Center Outreach Internship Digital Media Junior Specialist (Remote)"=>2,
		"WAWAC Pillar WA West African Center Health Programs (In Person/Onsite/Hybrid) (Working w/Minors)"=>7
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
	#puts "#{placements.size} Placements : #{placements.inspect}"
	#puts "Postions : #{positions.inspect}"
	#puts "#{choice1_group.size} Choice1 Group Left : #{choice1_group.inspect}"
	#puts "#{choice2_group.size} Choice2 Group : #{choice2_group.inspect}"

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