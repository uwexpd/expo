namespace :report do
  namespace :service_learning do
  
    desc "Find students who are placed in service-learning positions for the current quarter but no longer enrolled in the associated course(s)."
    task :find_placements_with_unenrolled_students => :environment do
      ActiveRecord::Base.connection.execute("SET sql_mode = 'ANSI'")
      all_placements = Quarter.current_quarter.service_learning_positions.collect(&:placements).flatten 
      all_placements.each{|p| puts "<ServiceLearningPlacement id: "+p.id.to_s+">: #{p.person.fullname} (#{p.position.title} at #{p.position.organization.name}) not in "+p.course.title if !p.person.nil? && !p.person.enrolled_service_learning_courses.include?(p.course)};"done"
    end

    desc "Get listing of organizations with service-learning students for the current quarter"
    task :organizations_with_service_learners => :environment do
      organization_quarters = OrganizationQuarter.find_all_by_quarter_id(Quarter.current_quarter).sort_by(&:organization)
      organization_quarters.each do |o|
        puts "#{o.organization.name.ljust(80)} #{o.placements.filled.size} students" unless o.placements.filled.empty?
      end
    end

    desc "Get listing of organizations with NO service-learning students for the current quarter"
    task :organizations_without_service_learners => :environment do
      organization_quarters = OrganizationQuarter.find_all_by_quarter_id(Quarter.current_quarter).sort_by(&:organization)
      organization_quarters.select{|oq| !oq.placements.empty? }.each do |o|
        puts "#{o.organization.name.ljust(80)} #{o.placements.filled.size} students" if o.placements.filled.empty?
      end
    end

    desc "Get listing of students who are in self-placements for the current quarter."
    task :find_self_placements => :environment do
      all_placements = Quarter.current_quarter.service_learning_positions.collect(&:placements).flatten.sort
      puts "Students in self-placements for #{Quarter.current_quarter.title}"
      all_placements.each{|p| puts "#{p.person.fullname.ljust(35)} #{p.position.title.ljust(60)} #{p.position.organization.name}" if p.position.self_placement? };"done"
    end

    desc "List all current positions that have some unallocated slots"
    task :unallocated_positions => :environment do
      quarter = ENV['quarter'] ? Quarter.find_by_abbrev(ENV['quarter']) : Quarter.current_quarter
      quarter.service_learning_positions.sort_by(&:organization).each do |position|
        puts "#{position.title[0..30].ljust(35)} #{position.organization.name[0..30].ljust(35)} Unallocated slots: #{position.number_of_slots_unallocated}" if position.number_of_slots_unallocated > 0
      end
    end

    desc "List all current positions that have no slots at all"
    task :unmatched_positions => :environment do
      quarter = ENV['quarter'] ? Quarter.find_by_abbrev(ENV['quarter']) : Quarter.current_quarter
      quarter.service_learning_positions.sort_by(&:organization).each do |position|
        puts "#{position.title[0..30].ljust(35)} #{position.organization.name[0..30].ljust(35)} #{position.placements.size} slots" if position.placements.empty?
      end
    end
    
    desc "List all current service-learners who are baby boomers"
    task :baby_boomers => :environment do
      quarter = ENV['quarter'] ? Quarter.find_by_abbrev(ENV['quarter']) : Quarter.current_quarter
      puts "Finding all #{quarter.title} service-learners who are baby boomers (born from 1946 through 1964)"
      quarter.service_learners.each do |p|
        puts "#{p.fullname.ljust(30)} #{p.sdb.birth_date.to_s}" if p.sdb.birth_date.year >= 1946 && p.sdb.birth_date.year <= 1964
      end
    end
    
  end
end