=begin rdoc
  Models a type of Service Learning opportunity for which a student can volunteer. Each position can have multiple ServiceLearningPlacements, or slots that are allocated to different classes and then reserved by a student.
  
  A ServiceLearningPosition belongs to an OrganizationQuarter, which links the position to a specific Quarter and Organization that is sponsoring the position. A position can also belong to another ServiceLearningPosition which is called the "previous" position, which allows us to link a position to its counterpart from a previous quarter. Since position details change significantly from Quarter to Quarter and they do not need a "parent" entity, this gives us enough information to show all previous related positions, even if the title or other significant detail has changed (e.g., "Database Assistant" changes to "Database Wizard" -- a wording change, but not really a significant change).
  
==Pipeline Positions
Pipeline Positions are ServiceLearningPositions that have the pipeline unit attached.
By default the Positions don't use slots, the slots are created and destroyed when a student is added.
To have a Pipeline Position use slots like a service learning position you have to set the flag 'uses_slots?' to true.
 - USE: This would be used if the position is for a specific course you can set it to use slots and then
   only create slots for that course.

Pipeline Courses are ServiceLearningCourses that have the pipeline unit.
  With a Pipeline Course the positions matches by default are set by using the filters.
  To have a Pipeline Course act like a service learning course you can set the 'no_filters' flag
  With the 'no_filters' flag set the course will only use positions that have slots for it, also the positions do not have to be set to 'uses_slots?'
  USE: This would be used for a course like the refugee seminar, where the positions for the course might not have any position attributes so you can then force the course to use the positions that have slots for the course

ServiceLearningPositions now have a many to many relationships to:
  pipeline_positions_subjects
  pipeline_positions_tutoring_types
  pipeline_positions_grade_levels
  
How a person is classified a volunteer:
  Attended an orientation and they are not in a pipeline course for the quarter you are comparing against
  Have a placement for the quarter and that placements course is NULL

How a person is considered an active pipeline volunteer
  pipeline_orientation <= 2 years old
  pipeline_background_check <= 2 years old
  pipeline_inactive != true

Students can only confirm positions for the current quarter.
  The confirm position method should not ever be reached for the non current quarter.
  The non current quarter should say "you can not confirm positions for this quarter" in last info box.
  Checks in PipelineController.confirm_position (incase it is reached).
  PipelineController.confirm_position  is the only method used by students to confirm positions.

ServiceLearningCourses now have a students field. The students field is a serialized hash of the students in the course.
  A 'sweeper' was added called ServiceLearningCourseSweeper it has the function self.update_students(quarter(s)) that updates the students field for all ow the courses for the passed quarter(s)
  Current Format: {Student.id=>{:course_id=>ServiceLearningCourseCourse.id}}  

ServiceLearningCourses also have one pipeline_course_filter
  It is a serialized list of filters set on the admin side
  This allows you to apply filters to a service learning course from that admin side that are forced on the student side
=end

class ServiceLearningPosition < ActiveRecord::Base

  default_scope :order => 'service_learning_positions.title'
  
  include ActionView::Helpers::TextHelper
  stampable
  
  acts_as_soft_deletable

  include ChangeLogged

  after_update :save_times
  
  before_save :create_orientation_if_needed
  def create_orientation_if_needed
    create_orientation if orientation.nil?
  end

  before_save :sanitize_user_input
  
  after_save :update_organization_quarter_counts
  after_destroy :update_organization_quarter_counts
  
  include Comparable
  belongs_to :location
  belongs_to :organization_quarter
  belongs_to :previous, :class_name => "ServiceLearningPosition", :foreign_key => "previous_service_learning_position_id"
  has_many :children, :class_name => "ServiceLearningPosition", :foreign_key => "previous_service_learning_position_id"
  belongs_to :supervisor, :class_name => "OrganizationContact", :foreign_key => "supervisor_person_id"
  belongs_to :orientation, :class_name => "ServiceLearningOrientation"
  has_many :times, :class_name => "ServiceLearningPositionTime", :dependent => :destroy
  has_many :placements, :class_name => "ServiceLearningPlacement", :dependent => :destroy do
    def filled
      find(:all, :conditions => 'person_id != 0')
    end
    # Limits the list of placements to only those associated with the passed object. _Obj_ can be either a ServiceLearningCourse or Person.
    def for(obj)
      if obj.is_a? Student
        find(:all, :conditions => ["#{obj.class.superclass.name.foreign_key} = ?", obj]) rescue []
      else
        find(:all, :conditions => ["#{obj.class.name.foreign_key} = ?", obj]) rescue []
      end
    end
    # Limits the list of placements to only those associated with the passed object but _also_ still considered and "open slot"
    # (i.e., person_id is null)
    def open_for(obj)
      unless obj.nil?
        find(:all, :conditions => ["#{obj.class.name.foreign_key} = ? AND (person_id <=> 0 OR person_id IS NULL) ", obj]) rescue []
      else
        find(:all, :conditions => ["service_learning_course_id IS NULL AND (person_id <=> 0 OR person_id IS NULL) "]) rescue []
      end
    end
    # Limits ONLY ONE of placements to those associated with the passed object but _also_ still considered and "open slot" (i.e., person_id is null)
    # To avoid race condiction by useing mysql FOR UPDATE # add pessimistic locking
    def open_for_place(obj)
      unless obj.nil?
        find(:all, :conditions => ["#{obj.class.name.foreign_key} = ? AND (person_id <=> 0 OR person_id IS NULL) ", obj], :limit => 1, :lock => true) rescue []
      else
        find(:all, :conditions => ["service_learning_course_id IS NULL AND (person_id <=> 0 OR person_id IS NULL) "], :limit => 1, :lock => true) rescue []
      end
    end
    # Limits the list of placements to only those that are not matched to a specific course yet.
    def unallocated
      find(:all, :conditions  => ["service_learning_course_id <=> 0 OR service_learning_course_id IS NULL"]) rescue []
    end
    # Find the open volunteer positions
    def open_volunteer
      find(:all, :conditions  => ["(service_learning_course_id <=> 0 OR service_learning_course_id IS NULL) AND (person_id <=> 0 OR person_id IS NULL)"]) rescue []
    end
  end
  has_one :selfplacement, :class_name => "ServiceLearningSelfPlacement", :dependent => :destroy
  
  has_many :placement_courses, :through => :placements, :source => :course
  
  named_scope :pending, :conditions => "approved IS NULL OR approved = 0"
  named_scope :for_unit, lambda { |unit| { :conditions => { :unit_id => unit.is_a?(Unit) ? unit.id : unit } } }
  
  has_and_belongs_to_many :skill_types
  has_and_belongs_to_many :social_issue_types
  
  attr_accessor :require_ideal_number_of_slots, :require_validations, :require_general_study_validations
  
  # By default, return true, unless we've specifically been told not to require this.
  def require_ideal_number_of_slots?
    require_ideal_number_of_slots || (require_ideal_number_of_slots.nil? ? true : require_ideal_number_of_slots)
  end
  
  # By default, return true, unless we've specifically been told not to require this.
  def require_validations?
    require_validations.nil? ? true : require_validations
  end
  
  def require_general_study_validations?
    require_general_study_validations.nil? ? false : require_general_study_validations
  end
  
  validates_presence_of :organization_quarter_id, :message => "is invalid. You must choose the UW unit that you're working with.", :if => :require_validations?
  validates_presence_of :supervisor_person_id, :message => "must be identified.", :if => :require_validations?
  validates_presence_of :ideal_number_of_slots, :if => :require_ideal_number_of_slots?, :if => :require_validations?
  validate :title_is_not_blank
  def title_is_not_blank
    errors.add(:title, "cannot be blank") if read_attribute(:title).blank?
  end
  validates_presence_of :description, :if => :require_general_study_validations?
  validates_presence_of :learning_goals, :if => :require_general_study_validations?
  validates_presence_of :academic_topics, :if => :require_general_study_validations?
  validates_presence_of :sources, :if => :require_general_study_validations?  
  validates_presence_of :total_hours, :if => :require_general_study_validations?
  validates_presence_of :credit, :if => :require_general_study_validations?
  validate :credit_is_valid, :if => :require_general_study_validations?
  def credit_is_valid     
     if (credit == 1 && total_hours < 30) || (credit == 2 && total_hours < 60) || (credit == 3 && total_hours < 90) || (credit == 4 && total_hours < 120) || (credit == 5 && total_hours < 150) || (credit == 6 && total_hours < 180)                   
       errors.add(:credit, "need to have enough required total hours.")
     end    
  end
  validates_presence_of :volunteer, :if => :require_general_study_validations?
  validates_format_of   :compensation, :with => /\A\d+(?:\.\d{0,2})?\z/, :allow_blank => true, :if => :require_general_study_validations?  
  
  belongs_to :unit, :class_name => "Unit"
  
  PLACEHOLDER_CODES = %w(title description context_description impact_description ideal_number_of_slots number_of_slots)
  PLACEHOLDER_ASSOCIATIONS = %w(organization quarter previous supervisor orientation location)
  
  has_many :service_learning_positions_sector_types_links, :foreign_key => "service_learning_position_id"
  has_many :service_learning_positions_sector_types, :through => :service_learning_positions_sector_types_links

  # Pipeline things
  has_many :pipeline_positions_subjects_links, :foreign_key => "pipeline_position_id"
  has_many :pipeline_positions_tutoring_types_links, :foreign_key => "pipeline_position_id"
  has_many :pipeline_positions_grade_levels_links, :foreign_key => "pipeline_position_id"
  has_many :pipeline_positions_language_spokens_links, :foreign_key => "pipeline_position_id"
  has_many :pipeline_positions_subjects, :through => :pipeline_positions_subjects_links
  has_many :pipeline_positions_tutoring_types, :through => :pipeline_positions_tutoring_types_links
  has_many :pipeline_positions_grade_levels, :through => :pipeline_positions_grade_levels_links
  has_many :pipeline_positions_language_spokens, :through => :pipeline_positions_language_spokens_links
  has_many :pipeline_positions_favorites, :foreign_key => "pipeline_position_id"
  has_many :pipeline_favorites, :through => :pipeline_positions_favorites, :source => :person
  
  has_many :service_learning_position_shares
  
  attr_accessor :new_number_of_slots, :new_times

  image_column :picture,
              :versions => { :mini => "45x28", :thumb => "70x43", :large => "268x166" },
              :store_dir => proc{|record, file| "shared/service_learning_position/#{record.id}/picture"}
  
  def <=>(o)
    title <=> o.title
  end
  
  # Used for change logs and other objects that request a unified "name" from this object.
  def identifier_string
    title
  end
  
  def name
    read_attribute :title
  end
  
  def title(show_self_placement = true, show_pending = true, html = true, require_validation = true, show_general_study = true)
    t = read_attribute :title
    pending_tag = html ? "<span class='pending tag'>pending</span>" : "[PENDING]"
    pending_tag = html ? "<span class='in_progress tag'>in progress</span>" : "[IN PROGRESS]" if in_progress
    invalid_tag = html ? "<span class='invalid tag'>invalid</span>" : "[INVALID]"
    self_placement_tag = html ? "<span class='self_placement tag'>self-placement</span>" : "(self-placement)"
    general_study_tag = html ? "<span class='general_study tag'>general-study</span>" : "(general-study)"
    t = "#{t} #{self_placement_tag}" if show_self_placement && self_placement?
    t = "#{t} #{general_study_tag}" if show_general_study && general_study?
    t = "#{t} #{pending_tag}" if show_pending && !approved?
    t = "#{t} #{invalid_tag}" if require_validation && !valid?
    t
  end
  
  # Returns the Organization object from the OrganizationQuarter relationship
  def organization
    organization_quarter.organization unless organization_quarter.nil?
  end
  
  # Returns the Quarter object from the OrganizationQuarter relationship  
  def quarter
    organization_quarter.quarter unless organization_quarter.nil?
  end
  
  # Returns the number of slots available for this position
  def number_of_slots
    @number_of_slots ||= placements.size
  end
  
  # Returns the number of slots that have been filled
  def number_of_slots_filled
    @number_of_slots_filled ||= placements.filled.size
  end
  
  # Returns the number of slots that have not yet been allocated to a course
  def number_of_slots_unallocated
    @number_of_slots_unallocated ||= placements.unallocated.size
  end
  
  # Returns true if this position's slots have all been filled for the associated object.
  def filled_for?(obj)
    placements.open_for(obj).empty?
  end

  # Provides a textual representation of this position, suitable for use in selection dropdowns. Accepts an optional
  # +service_learning_course+ which will show number of open slots for that course.
  def title_for_dropdown(service_learning_course = nil)
    t = "#{title}  at  #{organization.name}"
    if service_learning_course
      t << " - #{pluralize placements.open_for(service_learning_course).size, "slot"} open)"
    end
    t
  end
  
  # Sets the number of slots available for this position by creating or removing from the list of associated Placements.
  # This method will not remove slots that have already been assigned to a Person.
  # TODO: Have the unit_id be set on the placement creation, right now it is set when a student is placed.
  def number_of_slots=(number)
    number = number.to_i
    return if number == number_of_slots
    if number > number_of_slots
      (number - number_of_slots).times { |i| placements.build }
    else
      (number_of_slots - number).times do
        placements.find(:all, :conditions => "person_id IS NULL OR person_id = 0").pop.destroy rescue nil
      end
    end
  end
  
  # Matches slots to courses. Accepts a hash of slot_counts with course_id's as indices.
  def slots_for=(slots_hash)
    deltas = {}
    slots_hash.each do |course_id, slot_count|
      slot_count = slot_count.to_i
      course_id = course_id.to_i
      delta = slot_count - placements.for(ServiceLearningCourse.find(course_id)).size
      deltas.store(course_id, {:delta => delta, :slot_count => slot_count})
    end
    deltas.sort{|x,y| x[1][:delta]<=>y[1][:delta]}.each do |course_id, h|
      delta = h[:delta]; slot_count = h[:slot_count]; course = ServiceLearningCourse.find(course_id);
      if delta < 0
        delta.abs.times do
            placement = placements.for(course).select{|p|!p.filled?}.pop
            placement.update_attribute(:service_learning_course_id, nil) if placement.person_id.nil?          
        end
        
        # placements.for(course)[0..delta.abs-1].each do |placement|
        #   placement.update_attribute(:service_learning_course_id, nil) if placement.person.nil?
      elsif delta > 0
        placements.unallocated[0..delta-1].each do |placement|
          placement.update_attribute(:service_learning_course_id, course.id)
        end
      end
      
    end
  end
  
  def new_time_attributes=(time_attributes)
    time_attributes.each do |attributes|
      times.build(attributes)
    end
  end
  
  def existing_time_attributes=(time_attributes)
    times.reject(&:new_record?).each do |time|
      attributes = time_attributes[time.id.to_s]
      if attributes
        time.attributes = attributes
      else
        times.delete(time)
      end
    end
  end
  
  def save_times
    times.each do |time|
      time.save(false)
    end
  end
  
  # Returns a textual description of the placements and how they are allocated to courses for this Position. Pass an +exclude+ option to 
  # exclude a specific course from the breakdown list.
  def placements_breakdown(delimiter = ", ", options = {})
    collection = options[:exclude] ? placements.reject{|p| p.course == options[:exclude]} : placements
    return nil if collection.empty?
    t = ""
    courses = {}
    collection.each do |p|
      courses.include?(p.course) ? courses[p.course] = courses[p.course]+1 : courses[p.course] = 1
    end
#    courses.reject!{|c| c.course == options[:exclude]} if options[:exclude]
    courses.collect{|c,count| "#{c.title rescue "unallocated"} (#{count})"}.join(delimiter)
  end
  
  # Returns the courses that are allocated to this Position through ServiceLearningPlacement objects.
  def courses
    placement_courses.uniq
  end
  
  # Returns +true+ if this position still has open slots for the spceified ServiceLearningCourse.
  def open_for?(service_learning_course)
  end

  def location=(location_attributes)
    new_location_id = location_attributes.delete(:location_id)
    is_new_location = location_attributes.delete(:new_location)
    needs_update = location_attributes.delete(:needs_update)
    if location.nil? || is_new_location
      new_location = create_location(location_attributes)
      self.update_attribute(:location_id, new_location.id) if new_location.valid?
    elsif new_location_id.to_i == location_id.to_i && needs_update == "true"
      location.update_attributes(location_attributes)
    end
  end
  
  def orientation=(orientation_attributes)
    if orientation.nil?
      create_orientation(orientation_attributes)
    else
      orientation.update_attributes(orientation_attributes)
    end
  end

  # Returns true if this position is marked as valid for the specified time. Parameters:
  # 
  #  * time - The requested time, in string format
  #  * day - The day of the week in question, in string or symbol format
  #  * precise - If true, we check every ServiceLearningPositionTime precisely to the minute; otherwise, just check 
  #             against #timecodes (which only counts half-hour blocks, but is _much_ faster). Defaults to false.
  def time?(time, day, precise = false)
    if precise
      time = Time.parse(time.to_s) unless time.is_a?(Time)
      time = time.strftime("%H:%M:00")
      conditions = "start_time <= :time AND end_time >= :time AND #{day.to_s} IS true"
      !times.find(:first, :conditions => [conditions, { :time => time }]).nil?
    else
      timecode = "#{time}_#{day}"
      timecodes.include?(timecode)
    end
  end
  
  # Creates new times for this position based on a string of specifically-named IDs. Does not execute changes if the new
  # value is blank.
  # 
  # Parameter should be comma-delimited IDs like this: time_13:30_tuesday
  # New times are set with a 30 minute length, so if 11:00 is passed, the end time will be 11:29:59.
  # If the paramater is passed as "clear", then we just clear out the old times and return.
=begin
  def new_times=(new_times)
    return false if new_times.blank?
    times.clear
    return true if new_times == "clear"
    time_slot_length = 30.minutes - 1.second
    new_times.split(",").each do |time_id|
      regexp = /time_(\d+:\d+)_(\w+)/
      match = time_id[regexp]
      break if match.nil?
      start_time = Time.parse(match[$1])
      t = ServiceLearningPositionTime.new
      t[:start_time] = start_time
      t[:end_time] = start_time + time_slot_length
      t[match[$2]] = true
      t.save!
      times << t
    end
    new_times = nil
    times
  end
=end
  def new_times=(new_times)
    return false if new_times.blank?
    times.clear
    return true if new_times == "clear"
    
    # try and build time blocks as large as possible for each day
    day_hash = {}
    new_times.split(",").collect{|tr| tr.split("_")}.each do |t|
      day_hash[t[2]] ?  day_hash[t[2]] << t[1] : day_hash[t[2]] = [t[1]]
    end
    # day_hash = {"tuesday"=>["12:00", "12:30", "13:00"], "monday"=>["12:00", "12:30", "13:00"]}

    # swap the key and values to merge days that are the same
    day_time_hash = {}
    day_hash.each do |day,new_times|
      day_time_hash[new_times] ? day_time_hash[new_times] << day : day_time_hash[new_times] = [day]
    end

    day_array = []
    day_time_hash.each do |new_times,days|
      time_hash = {}
      start_time = nil
      end_time = nil
      new_times.each do |time|
        current_time = Time.parse(time)
        
        unless start_time.nil?
          # reset the end time if the next time is 30 minutes away
          if end_time == current_time
            end_time = current_time + 30.minutes
          else # else set the time hash and add it to the array then reset the start time, end time and time hash
            time_hash[:end_time] = end_time
            day_array << time_hash
            time_hash = {}
            start_time = nil
          end
        end
        
        # reset the start and end time if needed
        if start_time.nil?
          start_time = current_time
          end_time = current_time + 30.minutes
          time_hash[:start_time] = start_time
          for day in days
            time_hash[day] = true
          end
        end
        
      end
      
      # need to make the leftover day array entry
      time_hash = {}
      for day in days
        time_hash[day] = true
      end
      time_hash[:start_time] = start_time
      time_hash[:end_time] = end_time.to_s(:time) == "00:00" ? end_time - 1.second : end_time #set end_time 11:59 to display correctly instead of 00:00
      
      day_array << time_hash
      
    end
    
    day_array.each do |parameters|
      t = ServiceLearningPositionTime.create(parameters)
      t.save!
      times << t
    end
    times
    
  end
  
  # Clones this ServiceLearningPosition into a new ServiceLearningPosition object. Pass an array containing the names of the sets of 
  # attributes to include in the clone. Attribute sets include: +details+, +supervisor+, +location+, +times+. This method
  # does not allow the copying of orientation information or number of placements (or "slots"). Note: you should usually modify the
  # +organization_quarter_id+ of the returned object so that it applies to the correct quarter.
  def clone(copy_groups)
    p = nil
    
    p = ServiceLearningPosition.new({:previous_service_learning_position_id => self.id})
    
    p.update_attribute(:organization_quarter_id, self.organization_quarter_id)
    p.update_attribute(:unit_id, self.unit_id)
    attrs = []
    attrs << %w(title description context_description impact_description
                duration_requirement age_requirement skills_requirement
                other_age_requirement other_duration_requirement time_commitment_requirement
                background_check_required tb_test_required paperwork_requirement) if copy_groups.include?('details')
    attrs << %w(supervisor_person_id) if copy_groups.include?('supervisor')
    attrs << %w(location_id alternate_transportation) if copy_groups.include?('location')
    attrs << %w(time_notes times_are_flexible) if copy_groups.include?('times')
    attrs.flatten.each do |a|
      p[a] =  self.read_attribute(a)
    end
    p.title = title.to_s + " Copy" unless copy_groups.include?('details')
    p.save(false)
    if copy_groups.include?('times')
      times.each do |time|
        p.times.build time.attributes
      end
    end
    if copy_groups.include?('orientation_notes')
      p.build_orientation :notes => orientation.notes
    end
    
    # copy over the subjects, tutoring types and 
    if copy_groups.include?('pipeline_position')
      p.pipeline_positions_subject_ids = pipeline_positions_subject_ids
      p.pipeline_positions_grade_level_ids = pipeline_positions_grade_level_ids
      p.pipeline_positions_tutoring_type_ids = pipeline_positions_tutoring_type_ids
      p.pipeline_positions_language_spoken_ids = pipeline_positions_language_spoken_ids
      p.use_slots = use_slots
    end
    
    if copy_groups.include?('approved')
      p.approved = approved
    end
    
    if copy_groups.include?('ideal_number_of_slots')
      p.ideal_number_of_slots = ideal_number_of_slots
    end
    
    return p
  end
  
  # Returns true if this position has already been cloned into the specified OrganizationQuarter. This allows us to, for instance,
  # show a list of ServiceLearningPositions and note "this position has already been copied to this quarter." You can also pass
  # a Quarter object instead to check if the position has been cloned over to any OrganizationQuarter for a given Quarter.
  def cloned_to?(organization_quarter)
    if organization_quarter.is_a?(Quarter)
      for oq in organization.organization_quarters.for_quarter(organization_quarter)
        return true if cloned_to?(oq)
      end
      return false
    else
      !organization_quarter.positions.find_by_previous_service_learning_position_id(self.id).nil?
    end
  end
  
  # Returns true if +age_requirement+ is set to "Other". This does not examine the +other_age_requirement+ at all.
  def has_other_age_requirement?
    age_requirement == "Other"
  end
  
  # Returns true if +duration_requirement+ is set to "Other". This does not examine the +other_duration_requirement+ at all.
  def has_other_duration_requirement?
    duration_requirement == "Other"
  end
  
  # Collects an array of timecodes from each ServiceLearningPositionTime by calling #timecodes on each and flattening the results.
  def timecodes
    @timecodes ||= times.collect(&:timecodes).flatten.uniq
  end
  
  def subjects; pipeline_positions_subjects; end
  def tutoring_types; pipeline_positions_tutoring_types; end
  def grade_levels; pipeline_positions_grade_levels; end
  def languages; pipeline_positions_language_spokens; end
  
  def add_filled_slot
  end
  
  # Creates and fills a slot
  def add_filled_slot=(student_id)
    placements.create(:person_id => student_id)
  end
  
  # Updates the service learning postion's placement counts.
  # Called when a placement is created, saved or destroyed
  def update_placement_counts!
    counts = {
      :total_placements_count => placements.count,
      :filled_placements_count => placements.filled.count,
      :unallocated_placements_count => placements.unallocated.count
    }
    
    self.update_attributes(counts)
  end

  # Returns true if +sector id+ is set to 1 (Education & Youth Development) in table [service_learning_positions_sector_types]
  def education_sector?
    service_learning_positions_sector_type_ids.include?(1)
  end
  
  protected
  
  # Uses Rails' sanitize method to remove all HTML tags from all inputs except for the following tags:
  # +p, br, strong, em, b, i, ol, ul, li, a, img+
  # 
  # Also removes any IE conditional crap like +<!--[if+ and all that.
  def sanitize_user_input
    self.attributes.each do |name, value|
      if value.is_a?(String)
        value = ActionController::Base.helpers.sanitize(value, :tags => %w(strong em b i ol ul li a img p br))
        value = value.gsub("<p>&nbsp;</p>", "")
        value = value.gsub(/\[if(.*)\[endif\]/, "")
        value = value.strip
        self.write_attribute(name, value)
      end
    end
  end
  
  def update_organization_quarter_counts
    organization_quarter.update_position_counts! if organization_quarter
  end
  
end