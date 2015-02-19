# A ServiceLearningCourse is any group that is eligible to sign up for a ServiceLearningPosition. This is most often an official course (with a record in the SDB Time Schedule), but could also be an "unoffical" course (such as an Extension course or other course that does not appear in the Time Schedule), a program (such as the Pipeline Project, which sometimes hosts a few service learning groups), or simply another group of individuals who are participating in Service Learning. As a result, the term "Course" might be somewhat misleading for certain instances of this Model.
# 
# ServiceLearningCourses also each have many ServiceLearningCourseInstructors. Since the instructor data in the SDB is unreliable, we maintain this list on our own. This also allows us to track additional course instructors or TA's, both of which are often not listed in the SDB.
# 
# Finally, a ServiceLearningCourse has a ServiceLearningCourseStatus which is used during the Course Development process. See notes at ServiceLearningCourseStatus.
class ServiceLearningCourse < ActiveRecord::Base
  stampable
  after_update :save_courses
  attr_accessor :new_extra_enrollee
  acts_as_soft_deletable
  
  belongs_to :unit, :class_name => "Unit"
  belongs_to :quarter
  belongs_to :pipeline_student_type
  
  has_many :courses, :class_name => "ServiceLearningCourseCourse", :dependent => :destroy

  # These are for "at large" extra enrollees, meaning extra enrollees that are not tied to a Course (or if this ServiceLearningCourse
  # doesn't have any Courses attached)
  has_many :extra_enrollee_records, :class_name => "ServiceLearningCourseExtraEnrollee", :dependent => :destroy, :include => :person
  has_many :extra_enrollees, :through => :extra_enrollee_records, :source => :person

  has_many :notes, :as => :notable
  
  upload_column :syllabus, 
                :versions => [:original],
                :root_dir => File.join(RAILS_ROOT, 'files'), 
                :filename => proc { |record, file| "#{record.id.to_s}-Syllabus.#{file.extension}" },
                :store_dir => proc{ |record, file| File.join("service_learning_course", "syllabus", record.id.to_s) }
  
  has_many :statuses, :class_name => "ServiceLearningCourseStatus"
  has_many :placements, :class_name => "ServiceLearningPlacement", :dependent => :nullify, :include => :evaluation do
    # Limits the list of placements to only those associated with the passed object. _Obj_ can be either a ServiceLearningPosition or Person.
    def for(obj)
      find(:all, :conditions => ["#{obj.class.name.foreign_key} = ?", obj], :include => [{:position => :organization}, :evaluation]) rescue []
    end
    # Limits the list of placements to only those are that are still open (i.e., not associated with a Student)
    def open
      find(:all, :conditions => ["person_id is null"], :include => [:organization])
    end
  end
  has_many :positions, :through => :placements do
    def open
      find(:all, :conditions => ["person_id is null"]).uniq
    end
    def offered_by(organization)
      find :all, 
            :joins => "LEFT JOIN `organization_quarters` ON
                      (`service_learning_positions`.`organization_quarter_id`=`organization_quarters`.`id`)", 
            :conditions => { :organization_quarters => { :organization_id => organization.id } }
    end
  end
  has_many :instructors, :class_name => "ServiceLearningCourseInstructor"
  has_many :potential_course_organization_match_for_quarters
  has_many :potential_organizations, :through => :potential_course_organization_match_for_quarters, :source => :organization_quarter
  
  # holds a serialized list of the default filters used by the course set by the pipeline staff
  has_one :pipeline_course_filter
  
  # This holds a list of the students in the course
  # Format: {Student.id=>{:course_id=>ServiceLearningCourseCourse.id}} --ex-- {3333=>{:course_id=>225}, 90849=>{:course_id=>225}}
  # If the student is not linked with a course_course the has their ID points to is empty
  serialize :students
  
  validates_presence_of :quarter_id
  validates_associated :courses

  PLACEHOLDER_CODES = %w(title intructor_list)
  PLACEHOLDER_ASSOCIATIONS = %w(quarter unit)
  
  # Returns the most recent status (the current status)
  def status
    statuses.find(:first, :order => "updated_at DESC")
  end
  
  def <=>(o)
    title <=> o.title
  end
  
  # Returns the title of this course. If the +title+ attribute is blank, then look at the associated Course record and use its title
  def title
    alternate_title.blank? ? course_titles(" / ") : alternate_title
  end

  # Used for change logs and other objects that request a unified "name" from this object.
  def identifier_string
    title
  end
  
  attr_accessor :potential_organization_match
  def potential_organization_match=(new_potential_organization_id)
    potential_course_organization_match_for_quarters.create :organization_quarter_id => new_potential_organization_id
  end

  def delete_potential_organization_match(existing_potential_organization_id)
    potential_course_organization_match_for_quarters.find_by_organization_quarter_id(existing_potential_organization_id).destroy
  end
  
  # Returns the organizations that have positions matched with this course.
  def organizations
    positions.collect{|p| p.organization}.uniq.compact
  end
  
  def new_course_attributes=(course_attributes)
    course_attributes.each do |attributes|
      attributes[:course_branch] = Curriculum.find_by_curric_abbr(attributes[:dept_abbrev]).try(:curric_branch) || 0 rescue 0
      courses.build(attributes)
    end
  end
  
  def existing_course_attributes=(course_attributes)
    courses.reject(&:new_record?).each do |course|
      attributes = course_attributes[course.id.to_s]
      if attributes
        attributes[:course_branch] = Curriculum.find_by_curric_abbr(attributes[:dept_abbrev]).try(:curric_branch) || 0 rescue 0
        course.attributes = attributes
      else
        courses.delete(course)
      end
    end
  end
  
  # Returns all enrollees from all courses attached to this ServiceLearningCourse, including extra enrollees
  def enrollees
    @course_all_enrollees ||= courses.collect{|c| c.course.all_enrollees}
    @enrollees ||= (@course_all_enrollees + extra_enrollees).flatten.uniq #.sort{|x,y| x.fullname <=> y.fullname rescue -1}
  end
  
  # Returns just the count of enrollees (aka the class_size) in this class. This includes all attached course enrollees.
  def enrollee_count
    count = 0
    courses.each do |c|
      count += c.course.all_enrollee_count
    end
    count += extra_enrollees.size
    count
  end
  
  # Returns true if this course includes the specified Student in the roster.
  def enrolls?(student, options = {})
    options = {:include_extra_enrollees => true}.merge(options)
    courses.each do |c|
      return true if c.course.enrolls?(student, options)
    end
    return true if options[:include_extra_enrollees] == true && extra_enrollees.include?(student)
    false
  end
  
  # A course is open ("open for registration") when registration_open_time is in the past
  def open?
    registration_open_time < DateTime.now rescue false
  end

  # Toggles the +finalized+ attribute for this course. If marking this course as un-finalized and the course is
  #  currently marked as +open+, then unset the +open+ attribute as well. You can also pass a new value (true or false)
  # as a parameter to force it to that value.
  def toggle_finalized(value = nil)
    if value === nil
      new_value = !finalized?
    else
      new_value = value
    end
    update_attribute :finalized, new_value
    update_attribute :registration_open_time, nil if open? && !finalized?
    finalized?
  end

  # Toggles the +open+ attribute for this course by switching registration_open_time between nil and a time in the future.
  # You can also pass a new value (true or false) as a parameter to force it to that value.
  def toggle_open(value = nil)
    update_attribute :finalized, true if !finalized && !open?
    if value === nil
      new_value = self.open? ? nil : '1900-01-01 00:00:00'
    else
      new_value = (value == true || value == "true") ? '1900-01-01 00:00:00' : nil
    end
    update_attribute :registration_open_time, new_value
    open?
  end
  
  def instructor_list(delimiter = ", ")
    instructors.collect(&:fullname).join(delimiter)
  end

  # Collects all of the ContactHistory items from each of the instructors for this course. This is useful for adding contact
  # history logs to site notes.
  def contact_histories
    @contact_histories ||= instructors.collect(&:contact_histories).flatten
  end
  
  def pipeline_student_type_name
    pipeline_student_type.nil? ? "Unknown" : pipeline_student_type.name
  end

  # Create a copy sesrvice learning course
  def deep_clone!
    opts = {}
    opts[:except] = [        
        :updated_at
      ]
    self.clone(opts)  
  end    

  protected
  
  def save_courses
    courses.each do |course|
      course.save(false)
    end
  end
  
  def course_titles(delimiter = ', ')
    courses.collect{|c| c.short_title}.join(delimiter)
  end
 
end
