desc "Check if all Students have associated student records in our copy of UWSDB"
task :check_missing_student_records => :environment do
  Student.all.each{|s| puts "Missing student_no " + s.student_no if s.sdb.nil?}
end

desc "Import discipline categories from a file"
task :import_discipline_categories => :environment do
  puts "Loaded #{RAILS_ENV} environment."
  STDOUT.sync = true

  # Get file
  unless ENV['SOURCE_FILE']
    print "Input file path of CSV file: "
    file_path = $stdin.gets.strip
  else
    file_path = ENV['SOURCE_FILE']
  end
  lineno = 0

  puts "Parsing CSV file "
  file = CSV.open(file_path, 'r', ?,, ?\r)
  file.each do |p|
    lineno += 1
    next if lineno == 1
    name = p[1]
    major_abbr = p[0]
    dc = DisciplineCategory.find_or_create_by_name(name.titleize)
    major = MajorExtra.find_all_by_major_abbr(major_abbr)
    if major
      for m in major.each
        m.update_attribute(:discipline_category_id, dc.id)
        puts lineno.to_s.ljust(5) + "ADD   " + major_abbr
      end
    else
      puts lineno.to_s.ljust(5) + "ERR   " + major_abbr
    end
  end
  puts "\nDone."
end