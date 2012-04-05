class ActivityProjectUploadedFile

  require 'spreadsheet'

  # Pass a CGI::File to upload a new file or a String of the filename to find an existing file.
  def initialize(upload_file, department, year, quarters)
    @department = department
    @year = year
    @quarters = quarters
    @column_mapping = {}
    @column_mapping_errors = []
    @hours_attribute_name = "hours_per_week"
    
    if upload_file.is_a?(String)
      @filename = upload_file
    else      
      @filename = "individuals_#{Time.now.to_i.to_s}.xls"
      @upload_file = upload_file
      save_to_file!
    end
  end

  def inspect
    "#<ActivityProjectUploadedFile:#{file_path}>"
  end

  # Takes the uploaded file and saves the contents to disk for later use.
  def save_to_file!
    File.open(file_path(true), "wb") { |f| f.write(@upload_file.read) }
  end

  # These files are stored in RAILS_ROOT/files/activity_sources/:year/:department.hash()
  def file_path(create_if_needed = false)
    path = File.join(RAILS_ROOT, 'files', 'activity_sources', @year.to_s, @department.hash.to_s, @filename)
    FileUtils.mkdir_p(File.dirname(path)) if create_if_needed and !File.exists?(File.dirname(path))
    path
  end

  def filename
    @filename
  end
  
  # Getter method
  def column_mapping_errors
    @column_mapping_errors
  end

  # Contents of the user's upload file as a Spreadsheet::Worksheet object.
  def contents
    @contents ||= Spreadsheet.open(file_path).worksheet(0)
  end

  # The headings from the user's file as a Spreadsheet::Row object. Works like an array.
  def headings
    @headings ||= contents.row(0)
  end
  
  # Pass in the Rails params hash from the headings mapping to save it.
  def column_mapping=(mapping)
    @column_mapping = mapping if mapping.is_a?(Hash)
  end
  
  # Searches the user's file headings to get the index ID of the requested heading.
  def column_mapping_id(field_name)
    headings.index(@column_mapping[field_name])
  end
  
  # Returns true if we have a valid column header for all of our required fields.
  def valid_column_mapping?
    @column_mapping_errors = []
    if @column_mapping.empty?
      headings_options.each{|h| @column_mapping_errors << h }
      return false
    else
      headings_options.each do |h|
        @column_mapping_errors << h if @column_mapping[h].blank?
      end
    end
    @column_mapping_errors.delete("activity_type") if !@column_mapping["activity_type_override"].blank?
    @column_mapping_errors.empty?
  end
  
  def import_records!
    raise "Invalid column mapping" unless valid_column_mapping?
    @success = []
    @errors = []
    puts "Importing records from #{file_path}"
    Activity.transaction do
      contents.each(1) do |row|
        print "."
        attributes = {}
        quarter_columns = {}
        headings_options.each do |heading|
          # Activity types
          if heading == "activity_type" || heading == "activity_type_override"
            unless @column_mapping[:activity_type_override].blank?
              attributes[:activity_type_id] = @column_mapping[:activity_type_override].to_i
            else
              activity_type_value = row[column_mapping_id(heading)]
              guess_activity_type = ActivityType.find(:first, 
                                      :conditions => ["title LIKE ? OR abbreviation = ?",
                                      "%#{activity_type_value}%", activity_type_value[0..0]]) unless activity_type_value.blank?
              attributes[:activity_type_id] = guess_activity_type.try(:id)
            end

          # System key
          elsif heading == "student_id"
            val = row[column_mapping_id(heading)]
            next if val.blank?
            student = val.to_i != 0 ? StudentRecord.find_by_student_no("#{val}") : StudentRecord.find_by_uw_netid("#{val}")
            attributes[:system_key] = student.try(:system_key)
          
          # Quarters
          elsif heading.start_with?("hours_per_week_")
            quarter_columns[heading] = row[column_mapping_id(heading)]
          
          # All others
          else
            attributes[heading] = row[column_mapping_id(heading)]
          end
        end
        # Preparer
        attributes[:preparer_uw_netid] = User.current_user.try(:login)
      
        # Department
        if @department.is_a?(Department)
          attributes[:department_id] = @department.id
        elsif @department.is_a?(DepartmentExtra)
          if @department.dept_code.blank?
            attributes[:department_name] = @department.fixed_name
          else
            attributes[:department_id] = @department.dept_code
          end
        end
        
        # Create it
        activity = ActivityProject.create(attributes)
        if activity.valid?
          for heading,value in quarter_columns
            unless value.blank?
              quarter_abbrev = heading.match(/^hours_per_week_(\w{3}\d{4})/)[1]
              quarter = Quarter.find_by_abbrev(quarter_abbrev)
              activity.quarters.create(:quarter_id => quarter.id, @hours_attribute_name => value)
            end
          end
          @success << activity
        else
          @errors << row
        end
      end
    end
    return @errors, @success
  end
  
  def hours_are_totals=(val)
    @hours_attribute_name = val == "true" ? "number_of_hours" : "hours_per_week"
  end
  
  def headings_options
    rh = %w[ activity_type student_id title faculty_uw_netid faculty_name ]
    @quarters.each{|q| rh << "hours_per_week_#{q.abbrev}" }
    rh
  end
  
  def best_guess_heading(heading)
    case heading.to_s.downcase.gsub(" ","").gsub("_","")
      when "studentnumber" then :student_id
      when "studentno" then :student_id
      when "uwnetid" then :student_id
      when "netid" then :student_id
      when "title" then :title
      when "projecttitle" then :title
      when "activitytype" then :activity_type
      when "type" then :activity_type
      when "facultyuwnetid" then :faculty_uw_netid
      when "facultynetid" then :faculty_uw_netid
      when "facultymentorname" then :faculty_name
      when "facultymentor" then :faculty_name
      when "facultyname" then :faculty_name
      when "faculty" then :faculty_name
    end
  end
  
  def best_column_heading_match_for(heading_option)
    headings.select{|h| heading_option.to_s == best_guess_heading(h).to_s }
  end
  
end