=begin rdoc
An Activity models a person's participation in some sort of trackable activity. The primary purpose of the Activity models is to compile and generate accountability statistics for the provost and the legislature. We currently focus on two metrics for undergraduates: public service and research.

== How activities are stored
Activity is subclassed by a number of Activity varieties:

ActivityCourse::    for tracking an entire UW course for a particular quarter
ActivityProject::   for tracking an ongoing project, such as Students in Service, that lasts several weeks or even several quarters
ActivityEvent::     for tracking a one-time event, such as the MLK Day of Service, that has a more limited scope.

== Sources
The following data sources are used to calculate accountability statistics:

* Course lists provided by departments, including course_branch, course_no, dept_abbrev, and section_id for each course along
  with a Y/N for each quarter that the course should be counted. (Note: if section_id was not specified, we automatically pull
  _all_ sections for that course. In some cases this will result in duplicates but they will be removed during duplication
  processing).
* Individual student lists provided by departments
* Carlson Center service-learning participation (as tracked by EXPO) -- only for the public service report
* Applicants and group members of applications whose Offering has an ActivityType defined
  (currently, this includes Mary Gates Research scholarship [research], Mary Gates leadership scholarship [public service], 
  and the Undergraduate Research Symposium [research]). 
  * For session-based events (e.g., UGR Symposium), session presenters (all group members) are counted.
  * For non-research-based award offerings (e.g., Mary Gates Leadership), only awarded applicants are counted.
  * For research-based award offerings (e.g., Mary Gates Research), all complete applications (mentor approved) are counted.

== Intended Results
This system generates the following general types of statistics wherever possible:

[Student-quarters]    The number of quarters a student spent working in the given activity. 
                      One student for one quarter = 1 student-quarter.
                      One student for three quarters = 3 student-quarters.
                      Three students for one quarter = 3 student-quarters.
[Number of students]  The total number of _unique_ students who participated
[Number of hours]     A sum of all total number of hours that students participated
[Coverage]            The number/percentage of departments reporting information

== Accountability Methodology
This section describes the methodology used to calculate accountability statistics. All statistics are generated in groups based on the ActivityType of the given activity.

1. Raw Data Accumulation
   
   For each data source, pull relevant records. Calculate number of students and hours for each record.
    
   1. Student participation is gathered for department course lists:
      a. Each ActivityCourse that meets the requested criteria (e.g., "year = 2009") is validated against the SDB to verify
         that it is a valid course.
      b. For each course, the class enrollment is pulled, resulting in individual Student records.
      c. Students who withdrew, failed, or did not receive credit for the course are removed.
   2. Student participation is gathered from department individual participant lists.
   3. Student participation is gathered from EXPO's service-learning courses (ONLY for public service report).
   4. Student participation is gathered from EXPO's application system (ONLY matching ActivityTypes)

   Final result: hash with Students as keys and an activity array for each quarter, e.g.:
   
          Student_1_system_key   =>  {
            AutumnQuarter => [ActivityCourse, MaryGatesLeadershipApplication],
            SpringQuarter => [ServiceLearningCourse],
                           },
          Student_2_system_key   =>  {
            WinterQuarter => [ActivityEvent]
          }
          Student_3_system_key   => {
            :no_quarter => [ActivityProject]   # in rare cases, we don't know what quarters a project spanned
          }
          ...
          
    Details of how this hash is stored can be found in the documentation for #dump_results.

2. Removal of non-undergraduates

   For each student in the data hash, check each quarter of activity to ensure that the student was enrolled as an undergraduate
   during that quarter. Non-undergraduate quarters are removed. To do this, we look at the student's transcript record for that
   quarter.
   
   * If the quarter being evaluated is summer, the record is never removed, even if the student was not enrolled or not listed as
     an undergraduate for that quarter.
   * If there is no transcript record for that quarter and it is not summer, we remove it from the data hash.
   * If the "class" code for that quarter is higher than 5 and it is not summer, we remove it from the data hash.
   
   Notes:
   * For this report, "undergraduate" is any student with a class standing of 1, 2, 3, 4 or 5 (note that we do not
     include non-matriculated students but we do include "5th years").
   * If removing a quarter from a student in the data hash results in that student having no more valid quarters, the student is
     completely removed from the data hash and will not count toward any totals.
   * Any :no_quarter listings are still analysed based on the first quarter of the academic year being evaluated.

   Final result: same as in step #1, but only with the students' quarters that are valid.

3. Duplication Processing
   
   For each student in the data hash, process each duplication rule (see rule definitions below). As the processing happens,
   records that are removed are saved in a duplicates array for later review.
   
   1. Same quarter, same course
   2. Same quarter, multiple courses
   3. Same quarter, multiple activities
   
   Final result: same as in step #2, but only with the activities that should be counted in the final tally.
   
4. Statistics Calculation

   1. Student-quarters: sum of the count of each student's Quarter objects, plus any :no_quarter listings.
   2. Number of students: size of student data array.
   3. Number of hours: sum of number of hours per student; calculated differently based on the data source.
      a. Course list: number of credits the student _earned_ for the course, multiplied by the constant 
         COURSE_CREDIT_TO_HOURS_MULTIPLIER and the WEEKS_PER_QUARTER (10).
      b. Individual list: Hours are specified by department (as either hours per week or total hours per quarter)
      c. Carlson Center service-learning: 20 hours per quarter is used, as recommended by the Carlson Center
         (this is the minimum requirement by the CC)
      d. Application processes: use hours_per_week as specified by the student, if available. If hours_per_week is
         not available, we calculate the average number of hours for all students in the given activity type.
         * For award-based processes, multiply the calculated-hours-per-quarter times the number of requested award quarters
         * For event-based processes, the number of hours is only counted for the quarter during which the event occured.

5. Additional Reports

   * Department Sponsorship Breakdown: in what departments are these activities happening?
   * Department Cross-Pollination: e.g., how many BIO majors are doing research sponsored by medicine?
   * Demographic Analysis: majors, gender, class standing, and race/ethnicity of students participating.
   * Coverage: how many departments are represented/reported, broken down by college, discipline, and academic/admin.
     
=== Rules for duplicates
These rules define how we handle students who have multple records in a given quarter. Note that activities are always evaluated through the lens of a specific ActivityType, so these rules only apply to duplicates within the same ActivityType. For example, if a student participates in two research projects and one public service course in the same quarter, the public service course is not factored into the duplication processing of the two research projects.

Any time duplicates are removed, a Duplicates Report or Discrepancy Report is generated to allow for manual inspection and override.

Duplication processing details appear below.

=end
class AccountabilityReport < ActiveRecord::Base
  #extend ActiveSupport::Memoizable # Memoizable is deprecated in Rails 3.2. Use memoist gem instead then
    
  # Makes sure that we only count EXPO's service-learning courses for public service reports
  SERVICE_LEARNING_ACTIVITY_TYPE_ABBREVIATION = "S"
  ACCOUNTABILITY_CACHE = FileStoreWithExpiration.new("tmp/cache/accountability")
  
  belongs_to :activity_type
  validates_presence_of :quarter_abbrevs, :activity_type_id
  validates_uniqueness_of :quarter_abbrevs, :scope => :activity_type_id
  
  # Initializes a new AccountabilityReport. Specify an array or quarter abbreviations (e.g., "WIN2008") and an ActivityType
  # abbreviation (e.g., "S" or "R").
  def after_initialize
    @quarters = quarters
    @activity_type = activity_type
    # puts "Initializing AccountabilityReport..."
    # puts "   Quarters: #{@quarters.collect(&:title).join(", ")}"
    # puts "   ActivityType: #{@activity_type.title}\n"
    @results = {}
    @log_step = nil
    @overwrite_log = false
  end
  
  # Returns the possible years for all reports that have been created.
  def self.years
    Activity.find_by_sql("SELECT DISTINCT year FROM accountability_reports ORDER BY year").collect(&:year).collect(&:to_i)
  end
  
  def title
    return read_attribute(:title) unless read_attribute(:title).blank?
    "#{@activity_type.title} Accountability Report (#{quarters.collect(&:abbrev).join(", ")})"
  end
  
  def quarters
    @quarters ||= quarter_abbrevs.split.collect{|a| Quarter.find_by_abbrev(a.strip)} rescue nil
  end
  
  # Returns the location of YAML file that stores the student data hash based a key name.
  # The base path is +RAILS_ROOT/files/activity_results/results_[quarters_hash]_[activity_type_abbreviation]_[key].yml+
  def results_file_path(key)
    File.join(RAILS_ROOT, "files", "activity_results", "results_#{id.to_s}_#{key.to_s}.yml")
  end

  # Generates results for the specified key by calling the associated results method:
  # :raw::                  calls #accumulate_raw_data
  # :undergrads_only::      calls #remove_non_undergrads
  # :unique::               calls #remove_duplicates
  # :with_averages_added::  calls #inject_averages
  # :with_departments::     calls #inject_departments
  # 
  # Force a reload of previous steps' data by passing +true+ for :force.
  def generate_results(key, force = false)
    @log_step = key
    @overwrite_log = true if force
    puts "\n--"
    puts "Generating results: #{key.to_s}", true
    puts "Started at #{Time.now}\n"
    case key.to_sym
    when :raw                 then accumulate_raw_data(force)
    when :undergrads_only     then remove_non_undergrads(force)
    when :unique              then remove_duplicates(force)
    when :with_averages_added then inject_averages(force)
    when :with_departments    then inject_departments(force)
    else raise Exception.new("Invalid key. Try one of :raw, :undergrads_only, :unique, :with_averages_added, or :with_departments.")
    end
    @log_step = key
    update_status("Generated on #{generated_at.to_s(:date_at_time12)}") if generated_at
    results_file_path(key)    
  end
  
  # Alias for generate_results(key, true)
  def generate_results!(key)
    generate_results(key, true)
  end
  
  # Returns the DateTime that this report's results were generated by looking at the last-modified date of the results file
  # used for final statistics (with the key "with_departments"). Returns nil if that results file doesn't exist.
  def generated_at
    return nil unless File.exist?(results_file_path(:with_departments))
    File.mtime(results_file_path(:with_departments))
  end
  
  # Stores a status message into a file that can be read at any time.
  def update_status(msg)
    status_file_path = File.join(RAILS_ROOT, "files", "activity_results", "status_#{id.to_s}.log")
    File.open(status_file_path, 'w') {|f| f << msg }
  end
  
  # Returns the current status message that's stored in the status file.
  def status
    status_file_path = File.join(RAILS_ROOT, "files", "activity_results", "status_#{id.to_s}.log")
    return nil unless File.exists? status_file_path
    File.open(status_file_path, 'r').read
  end
  
  # Reads a report's status without having to instantiate the object.
  def self.status(id)
    status_file_path = File.join(RAILS_ROOT, "files", "activity_results", "status_#{id.to_s}.log")
    return nil unless File.exists? status_file_path
    File.open(status_file_path, 'r').read    
  end

  # Returns true if this report is currently being generated.
  def in_progress?
    return false unless status
    status.match(/^Generated on/).nil?
  end
  
  # Returns true if the report's status indicates that it's still processing (i.e., if status is anything other than "Generated on...")
  def self.in_progress?(id)
    return false unless AccountabilityReport.status(id)
    AccountabilityReport.status(id).match(/^Generated on/).nil?
  end

  # Creates a status file and writes to start
  def self.mark_as_in_progress(id)
    status_file_path = File.join(RAILS_ROOT, "files", "activity_results", "status_#{id.to_s}.log")
    File.open(status_file_path, 'w') {|f| f << "Regenerating..." }
  end
  
  # Calculates the totals for all records in the data hash.
  def final_statistics(force = false)
    @log_step = nil
    load_results(:with_departments, force) if force || @results.empty?
    update_status("Generated on #{generated_at.to_s(:date_at_time12)}") if generated_at
    puts "Calculating final statistics."
    stats = {:department => {}}
    default_quarter_hash = {}
    stats[:total] = {
      :number_of_students => @results.size,
      :student_quarters => @results.values.collect(&:size).sum.to_i,
      :average_quarters_per_student => @results.values.collect(&:size).average.to_f,
      :quarters => {},
      :courses => []
    }
    for quarter in @quarters
      default_quarter_hash[quarter.abbrev] = {
        :number_of_students => 0,
        :number_of_hours => 0,
        :courses => []
      }
    end
    stats[:total][:quarters] = default_quarter_hash.clone
    for system_key, quarter_hash in @results
      for quarter_abbrev, activities in quarter_hash
        stats[:total][:quarters][quarter_abbrev][:number_of_students] += 1
        hours_to_add = activities.collect{|a| a[:number_of_hours] unless a[:duplicate]==true}.compact.sum.to_i
        stats[:total][:quarters][quarter_abbrev][:number_of_hours] += hours_to_add

        # Add in department info
        for activity in activities
          unless stats[:department][activity[:department]]
            stats[:department][activity[:department]] = { :quarters => {} }
            for quarter in @quarters
              stats[:department][activity[:department]][:quarters][quarter.abbrev] = {
                :number_of_students => 0,
                :number_of_hours => 0,
                :courses => []
              }
            end
          end
          
          unless activity[:course].blank?
            unless stats[:department][activity[:department]][:quarters][quarter_abbrev][:courses].include?(activity[:course])
              stats[:department][activity[:department]][:quarters][quarter_abbrev][:courses] << activity[:course] 
            end 
          end
          stats[:department][activity[:department]][:quarters][quarter_abbrev][:number_of_students] += 1
          stats[:department][activity[:department]][:quarters][quarter_abbrev][:number_of_hours] += activity[:number_of_hours].to_f
          
          stats[:department][activity[:department]][:total] ||= { :students => [] }
          stats[:department][activity[:department]][:total][:students] << system_key
          
          # if activity.is_a?(ActivityCourse)
          # stats[:total][:quarters][quarter_abbrev][:courses] << 
          
        end

        # Add in reporting_department info
        for activity in activities
          unless activity[:reporting_department].blank?
            unless stats[:department][activity[:reporting_department]]
              stats[:department][activity[:reporting_department]] = { :quarters => {} }
              for quarter in @quarters
                stats[:department][activity[:reporting_department]][:quarters][quarter.abbrev] = {
                  :number_of_students => 0,
                  :number_of_hours => 0,
                  :courses => []
                }
              end
            end
            stats[:department][activity[:reporting_department]][:quarters][quarter_abbrev][:number_of_students] += 1
            stats[:department][activity[:reporting_department]][:quarters][quarter_abbrev][:number_of_hours] += activity[:number_of_hours].to_f
          
            stats[:department][activity[:reporting_department]][:total] ||= { :students => [] }
            stats[:department][activity[:reporting_department]][:total][:students] << system_key
          end
        end
      end
    end
    stats[:total][:number_of_hours] = stats[:total][:quarters].collect{|k,v| v[:number_of_hours]}.sum.to_i
    stats[:total][:average_hours_per_student] = stats[:total][:number_of_hours] / stats[:total][:number_of_students].to_f
    stats
  end
  
  # Calculates the totals by courses for all ServiceLearningPlacement in the data hash. Display this information in reporting course in accountability
  def service_learning_course_statistics(department, force = false)
    ACCOUNTABILITY_CACHE.fetch("accountability_report_#{self.id}_for_department_#{department.dept_code}_stats", :expires_in => 24.hours) do
      load_results(:with_departments, force) if force || @results.empty?
      stats = {:department => {}}
            
      for system_key, quarter_hash in @results
        for quarter_abbrev, activities in quarter_hash
        
          for activity in activities       
              klass, id = activity[:activity].split("_")
              a = klass.constantize.find(id) rescue nil
            
              department_id, department_name = activity[:department].split("_")
            
              if a.is_a?(ServiceLearningPlacement) && department_id.to_i == department.dept_code
                unless stats[:department][activity[:department]]
                  stats[:department][activity[:department]] = { :quarters => {} }
                  for quarter in @quarters
                    stats[:department][activity[:department]][:quarters][quarter.abbrev] = { :courses => {} }
                  end
                end
              
                unless activity[:course].blank?                
                  if stats[:department][activity[:department]][:quarters][quarter_abbrev][:courses].include?(activity[:course])
                     stats[:department][activity[:department]][:quarters][quarter_abbrev][:courses][activity[:course]] += 1
                  else
                    stats[:department][activity[:department]][:quarters][quarter_abbrev][:courses][activity[:course]] = 1
                  end                                               
                end
                               
              end                  
          end  
                                               
        end
      end    
      stats
    end
  end
  #memoize :service_learning_course_statistics
  #Comment this out because it only improves about 1.5 second and we need to dyamically reload the data when regerenate, not a good fit for this method.

  protected

  def puts(s, update_status_too = false)
    update_status(s) if update_status_too
    print(s + "\n")
  end
  
  def print(s)
    log(s)
    Kernel.print(s)
  end
  

  # Stores the following values for a specific activity into the results hash.
  # 
  # :activity::         The activity that resulted in this record being added to the hash. This is often an Activity or related record
  #                     (like an ActivityCourse), but could be a ServiceLearningPlacement or other EXPO object.
  # :source::           This is the actual object that was used to calculate the number of hours. For example, if the :activity is an
  #                     ActivityCourse, this :source might be an individual StudentRegistrationCourse object. This is done because a
  #                     student may have taken the course for variable credit and so we cannot rely on the number of credits from the
  #                     course itself. For activity objects outside the Activity space, like an Offering, this might be a specific item
  #                     like an ApplicationForOffering. In some cases, :activity and :source could be the same.
  # :number_of_hours::  The number of hours calculated for this activity, calculated using the #number_of_hours method.
  # 
  # The format of the results hash is:
  #     Student_system_key => {
  #           quarter_abbrev => [ :activity => "ModelName_id",
  #                               :source => "ModelName_id",
  #                               :number_of_hours => 140.0,
  #                             ]
  #           }
  def add_result(system_key, quarter, activity, source)
    @results[system_key] = {} if @results[system_key].nil?
    h = @results[system_key]
    h[quarter.abbrev] = h[quarter.abbrev] || []
    data = {
      :activity =>        "#{activity.class.to_s}_#{activity.id}",
      :source =>          "#{source.class.to_s}_#{source.id}",
      :number_of_hours => Activity.number_of_hours(source)
    }
    h[quarter.abbrev] << data
    @results
  end
  
  # Dumps the students results hash into a YAML file for later retreival (or caching). You must pass a key that identifies
  # what type of result this is in the process:
  # 
  # raw::                 After the raw data accumulation
  # undergrads_only::     After removal of non-undergrads
  # unique::              After duplication processing
  # with_averages_added:: After the average number of hours have been calculated and inserted into the results with no hours.
  #
  def dump_results!(key)
    file_path = results_file_path(key)
    File.open(file_path, "w") do |f|
      f.write @results.to_yaml
    end
    file_path
  end

  def log(s)
    access = 'a'
    if @overwrite_log
      access = 'w'
      @overwrite_log = false
    end
    File.open(log_file_path, access) do |f|
      f << s
    end
  end
  
  def log_file_path
    File.join(RAILS_ROOT, "files", "activity_results", "results_#{id.to_s}_#{@log_step.to_s}.log")
  end
  
  # Loads the results array from the YAML file cache produced by #dump_results!. If the cache file doesn't exist, this method
  # regenerates the necessary results by calling generate_results!(key). To force this regeneration, pass +true+ for the +force+
  # parameter.
  def load_results(key, force = false)
    @log_step = key
    file_path = results_file_path(key)
    print "Loading results from #{file_path}... "
    if File.exist?(file_path)
      if force
        puts "force reload requested.\nForcing regeneration of #{key.to_s} results to #{file_path}..."
        return generate_results!(key)
      end
      @results = YAML::load(File.open(file_path))
      puts "done."
      puts "Read #{@results.size} results from #{File.mtime(file_path).to_s(:long)}"
    else
      puts "not found."
      @log_step = key
      generate_results!(key)
    end
  end
  
  # Accumulates the raw data from each source and dumps it into the results file.
  def accumulate_raw_data(force = false)
    puts "Accumulating: ActivityCourse... ", true
    for quarter in @quarters
      activity_courses = ActivityCourse.of_type(@activity_type).for_quarter(quarter)
      print "  #{quarter.abbrev}: #{activity_courses.size.to_s.ljust(4)} "
      for activity_course in activity_courses
        for registrant in activity_course.registrants
          if !registrant.failed? && !registrant.credits.zero?
            add_result(registrant.system_key, quarter, activity_course, registrant)
          end
        end
        print "."
      end
      print "\n"
    end
    puts "\n#{@results.size} unique students."
    puts "Saved results output to #{dump_results!(:raw)}"
    
    puts "Accumulating: ActivityProject... ", true
    activity_projects = ActivityProject.of_type(@activity_type).for_quarter(@quarters)
    for activity_project in activity_projects
      print "|"
      for activity_quarter in activity_project.quarters
        if @quarters.include?(activity_quarter.quarter)
          add_result(activity_project.system_key, activity_quarter.quarter, activity_project, activity_quarter)
          print "."
        end
      end
    end
    print "\n"
    puts "\n#{@results.size} unique students."
    puts "Saved results output to #{dump_results!(:raw)}"
    
    puts "Accumulating: ServiceLearningPlacement... ", true
    if @activity_type.abbreviation == SERVICE_LEARNING_ACTIVITY_TYPE_ABBREVIATION
      for quarter in @quarters
        print "  #{quarter.abbrev}: "
        placements = quarter.service_learning_placements.select(&:filled?)
        print "#{placements.size.to_s.ljust(4)} "
        for placement in placements
          system_key = placement.person.is_a?(Student) ? placement.person.system_key : nil
          if system_key
            add_result(system_key, quarter, placement, placement)
            print "."
          else
            print "X"
          end
        end
        print "\n"
      end
    else
      print "  (skipping)"
    end
    print "\n"
    puts "\n#{@results.size} unique students."
    puts "Saved results output to #{dump_results!(:raw)}"

    puts "Accumulating: ApplicationForOfferings... ", true
    for quarter in @quarters
      print "  #{quarter.abbrev}: "
      offerings_by_quarter = Offering.find_all_by_activity_type_id_and_quarter_offered_id(@activity_type, quarter)
      offerings_by_acc_quarter = Offering.find_all_by_activity_type_id_and_accountability_quarter_id(@activity_type, quarter)
      offerings = (offerings_by_quarter + offerings_by_acc_quarter).flatten
      puts "#{offerings.size.to_s.ljust(4)}"
      for offering in offerings
        print "    #{offering.title.ljust(40)}: "
        if offering.count_method_for_accountability.blank?
          puts "No count method defined" 
          next
        end
        apps = offering.accountability_objects
        print "#{apps.size}\n      "
        for app in apps
          print "|"
          system_key = app.respond_to?(:person) ? app.person.try(:system_key) : app.system_key
          if system_key.nil?
            print "?"
            next 
          end
          if offering.accountability_quarter
            add_result(system_key, quarter, offering, app)
            print "."
          else
            for award in app.awards.valid
              if @quarters.include?(award.requested_quarter)
                add_result(system_key, award.requested_quarter, offering, award)
                print "#{award.number_of_hours.to_s}/"
              else
                print "X/"
              end
            end
          end
        end
        print "\n"
      end
    end
    print "\n"
    puts "\n#{@results.size} unique students."
    puts "Saved results output to #{dump_results!(:raw)}"
  end

  def remove_non_undergrads(force = false)
    load_results(:raw, force) if force || @results.empty?
    @log_step = :undergrads_only
    @overwrite_log = true
    puts "Removing non-undergraduates quarters", true
    for system_key, quarter_hash in @results
      student = StudentRecord.find(system_key)
      for quarter_abbrev, activities in quarter_hash
        quarter = Quarter.find_by_abbrev(quarter_abbrev)
        next if quarter.quarter_code_id == 3 # skip if it's a summer quarter
        if @quarters.include?(quarter) && !student.undergrad_during_quarter?(quarter)
          quarter_hash.delete(quarter_abbrev)
          puts "DELETE QUARTER   #{system_key} had class code #{student.class_standing(quarter)} in #{quarter.title}"
          puts "                 #{activities.collect{|x| x[:source]}.join(", ")}"
        end
      end
      if quarter_hash.empty?
        @results.delete(system_key)
        puts "DELETE STUDENT   #{system_key} has no more valid quarters of activity"
      end
    end
    puts "\n#{@results.size} unique students."
    puts "Saved results output to #{dump_results!(:undergrads_only)}"
  end
  
  def remove_duplicates(force = false)
    load_results(:undergrads_only, force) if force || @results.empty?
    @log_step = :unique
    @overwrite_log = true
    puts "Removing duplicates from results", true
    puts "Duplication rules => SameCourse: ON, MultipleCourses: OFF, MultipleActivities: ON"
    for system_key, quarter_hash in @results
      removals = false
      for quarter_abbrev, activities in quarter_hash
        if activities.size <= 1
          # puts "OK (single activity)"
        else
          original_activity_count = activities.size
          arq = AccountabilityReportQuarter.new(quarter_abbrev, activities)
          if arq.report.blank?
            # puts "OK (no conflicts to remove)"
          else
            print "\n  #{system_key.to_s.ljust(10)} "
            print "#{quarter_abbrev} (#{original_activity_count}) ".ljust(20)
            # arq.activities_to_remove.each{|to_remove| activities.delete(to_remove)}
            puts arq.report + "\n                                 Left with #{activities.size} activities."
            # puts activities.to_yaml.gsub("\n", "\n                                 ")
            removals = true
          end
        end
        print "." unless removals
      end
    end
    puts "\n#{@results.size} unique students."
    puts "Saved results output to #{dump_results!(:unique)}"
  end
  
  # Calculates the average number of hours of all non-course, non-duplicate activities for each quarter and then
  # injects that into any activity without a +number_of_hours+ value defined.
  def inject_averages(force = false)
    load_results(:unique, force) if force || @results.empty?
    @log_step = :with_averages_added
    @overwrite_log = true
    puts "Collecting quarter totals", true
    puts "_ = Number of hours is blank      D = Duplicate (do not touch)     . = Number of hours is not blank"
    totals = {}
    average = {}
    for quarter in @quarters
      totals[quarter.abbrev] = []
    end
    for system_key, quarter_hash in @results
      for quarter_abbrev, activities in quarter_hash
        for activity in activities
          if activity[:number_of_hours].blank?
            print "_"
          elsif activity[:duplicate] == true
            print "D"
          else
            totals[quarter_abbrev] << activity[:number_of_hours] 
            print "."
          end
        end
      end
    end
    print "\n"
    puts "Calculating quarter averages", true
    for quarter in @quarters
      average[quarter.abbrev] = totals[quarter.abbrev].average
    end
    pp average
    puts "Injecting quarter averages into results", true
    puts "I = Average was injected      D = Average was injected (but record is duplicate)     . = No action needed"
    for system_key, quarter_hash in @results
      for quarter_abbrev, activities in quarter_hash
        for activity in activities
          if activity[:number_of_hours].blank?
            activity[:number_of_hours] = average[quarter_abbrev]
            print(activity[:duplicate] == true ? "D" : "I")
          else
            print "."
          end
        end
      end
    end
    puts "\n#{@results.size} unique students."
    puts "Saved results output to #{dump_results!(:with_averages_added)}"
  end

  # Inserts the department identifier into the activity hash in the form "<department ID or zero>_<department full name>" using
  # the following rules:
  # 
  # * For activities with a department_id defined in the Activity record, we use that department
  # * For ActivityCourse records, a separate "reporting department" can be specified, in which case we populate a
  #   :reporting_department attribute in the hash (as long as the reporting department is not the same as the activity department).
  # * For ServiceLearningPlacements, the department is set as "0_Carlson Center". In June, 2011, break down Carlson Center Placement to departments and inject courses.
  # * For objects that have an associated Unit in EXPO (e.g., Scholarship offerings and symposium), the department is set
  #   as "0_<unit name>"
  # * For all others, the the department is set as "0_<department_name>"
  def inject_departments(force = false)
    load_results(:with_averages_added, force) if force || @results.empty?
    @log_step = :with_departments
    @overwrite_log = true
    puts "Injecting department identifiers into results", true
    # puts ". = Department was found in SDB     0 = Department was not found in SDB    E = Source is EXPO so sponsoring unit is used   R = Extra reporting department was specified and added"
    for system_key, quarter_hash in @results
      for quarter_abbrev, activities in quarter_hash
        for activity in activities          
          course_identifier = nil
          service_learning_department_identifier = nil
          
          klass, id = activity[:activity].split("_")
          a = klass.constantize.find(id) rescue nil
          print system_key.to_s.ljust(11)
          print "department: #{(a.department_name || a.department_id rescue nil).to_s[0..47]}".ljust(62, ".")          
          
          if a.is_a?(Activity) && !a.department_id.blank?
            department_identifier = "#{a.department_id.to_s}_#{a.department.try(:name)}"
            # print "."
          elsif a.is_a?(ServiceLearningPlacement)
              if a.course
                for c in a.course.courses
                   if c.course.enrolls?(Person.find(a.person_id))
                      department_identifier = "#{c.course.department.dept_code.to_s}_#{c.course.department.try(:name)}"
                      course_identifier = "#{c.course.short_title}"                           
                   end
                end
              else
                department_identifier = "No registered course, Volunteer"
              end
              
              if a.unit_id == 4
                service_learning_department_identifier = "0_Pipeline Project"  
              else
                service_learning_department_identifier = "0_Carlson Center"                                
              end              
                          
            # print "E"
          elsif a.respond_to?(:unit)
            department_identifier = "0_#{a.unit.name}"
            # print "E"
          else
            department_identifier = "0_#{a.department_name}"
            # print "0"
          end
          activity[:department] = department_identifier          
          puts department_identifier
          activity[:course] = course_identifier
          print "           course: ".ljust(73, ".")
          puts activity[:course] || "nil (not specified)"
          activity[:reporting_department] = service_learning_department_identifier
        end             
        
        if a.is_a?(ActivityCourse)
          print "           reporting_department: #{(a.reporting_department_name || a.reporting_department_id).to_s[0..37]}".ljust(73, ".")
          if !a.reporting_department_id.blank?
            reporting_department_identifier = "#{a.reporting_department_id.to_s}_#{a.reporting_department.try(:name)}"
          elsif !a.reporting_department_name.blank?
            reporting_department_identifier = "0_#{a.reporting_department_name}"
          else
            reporting_department_identifier = nil
          end
          if reporting_department_identifier && reporting_department_identifier != department_identifier
            activity[:reporting_department] = reporting_department_identifier
          end
          puts activity[:reporting_department] || "nil (same as department, or not specified)"
        end
      end
    end
    puts "\n#{@results.size} unique students."
    puts "Saved results output to #{dump_results!(:with_departments)}"
  end
  
  # Used to check each duplication rule for a specific quarter of activity of a student.
  class AccountabilityReportQuarter
    
    def initialize(quarter_abbrev, activities)
      @quarter_abbrev = quarter_abbrev
      @activities = activities
      @reports = []
      @activities_to_remove = []
      run_checks
    end
  
    def run_checks
      check_same_course
      # check_multiple_courses
      check_multiple_activities
    end
  
    # Same quarter, same course: If a student is enrolled in the same course for the same course_no (e.g., they are enrolled in both a
    # lecture section and a quiz section for the same course), only the section with the larger number of credits are counted.
    def check_same_course
      for activity in @activities
        source = source(activity)
        if source.is_a?(StudentRegistrationCourse)
          for other_activity in @activities.reject{|a| a == activity}
            other_source = source(other_activity)
            if type(other_activity) == StudentRegistrationCourse && source.crs_number == other_source.crs_number
              # it's the same course number... now pick which one to delete
              if activity[:number_of_hours] <= other_activity[:number_of_hours]
                remove_activity(activity)
                report = "[SameCourse]: DEL #{activity[:source]} "
                report << "(#{activity[:number_of_hours]} hours <= #{other_activity[:number_of_hours]} hours)"
                @reports << report
              end
            end
          end
        end
      end   
    end

    # Same quarter, multiple courses: Students receiving credit for multiple courses in the same quarter are not de-duped, unless
    # the faculty mentor/instructor is listed as the same for both course.
    def check_multiple_courses
      
    end
    
    # Same quarter, multiple activities: Students who have multiple activities for the same quarter will only count the larger of 
    # the number of hours. Note that for this rule, activities are not actually removed from the data hash; instead, they are
    # marked with a "duplicate" flag so they are not double counted in the final statistics but can still be counted separately
    # for different department counts.
    def check_multiple_activities
      if @activities.size > 1
        sorted = @activities.sort_by{|a| a[:number_of_hours].to_f}.reverse
        # puts sorted.collect{|a| a[:number_of_hours]}.join(" > ")
        max_hours = sorted.first[:number_of_hours]
        for activity in sorted[1..sorted.size]
          remove_activity(activity, false)
          report = "[MultipleActivities]: DUP #{activity[:source]} "
          report << "(#{activity[:number_of_hours]} hours <= #{max_hours} hours)"
          @reports << report
        end
      end
    end

    # Removes an activity. Specify "false" as the second parameter to mark the item as a duplicate instead of deleting it from the hash.
    def remove_activity(activity, delete_from_hash = true)
      activity[:duplicate] = true
      @activities_to_remove << activity && @activities.delete(activity) if delete_from_hash
    end
    
    def activities_to_remove
      @activities_to_remove
    end
    
    def report
      @reports.join("\n                                 ")
    end
    
    private
        
    def source(activity)
      klass, id = activity[:source].split("_")
      klass.constantize.find(id) rescue nil
    end
    
    def type(activity)
      klass, id = activity[:source].split("_")
      klass.constantize
    end
  
  end
  
end
