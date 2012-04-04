# Models the relationship between a ServiceLearningCourse and a Course from the Student DB Time Schedule.
class ServiceLearningCourseCourse < ActiveRecord::Base
  stampable
  belongs_to :service_learning_course
  belongs_to :course, :class_name => "Course", :foreign_key => %w(ts_year ts_quarter course_branch course_no dept_abbrev section_id)
  
  validates_presence_of :service_learning_course_id
  validates_presence_of :ts_year, :ts_quarter, :course_branch, :course_no, :dept_abbrev, :section_id
  validates_associated :course
  validates_presence_of :course, :message => "is not a valid course in the time schedule"
  
  delegate :full_title, :course_title, :department, :registrants, :to => :course
  
  def <=>(o)
    short_title <=> o.short_title
  end
  
  def self.find_by_abbrev(param)
    match = param.match(/(\D+?)(\d+?)(\D+?)/)
    self.find_by_dept_abbrev_and_course_no_and_section_id match[1], match[2], match[3]
  end
  
  # Finds the first record whose course abbreviation matches the passed parameter and exists for the specified quarter.
  # Pass the course abbreviation with no spaces, like "SOC110A" for SOC 110 A. This is useful for passing in URL's.
  # 
  # Optional: pass a unit object as the final parameter to limit results to those in courses that belong that unit.
  # FIXME: fix this so that we don't manually process the results when filtering by unit.
  def self.find_by_abbrev_and_quarter(param, quarter = Quarter.current_quarter, unit = nil)
    match = param.match(/(\D+?)(\d+?)(\D+?)/)
    results = self.find_all_by_dept_abbrev_and_course_no_and_section_id_and_ts_year_and_ts_quarter(
                  match[1], match[2], match[3], quarter.year, quarter.quarter_code_id
                )
    unit.nil? ? results.first : results.select{|r| r.service_learning_course.unit_id == unit.try(:id)}.first
  end
  
  def abbrev
    "#{dept_abbrev}#{course_no}#{section_id}"
  end
  
  def short_title
    "#{dept_abbrev.to_s.strip} #{course_no.to_s.strip} #{section_id.to_s.strip}"
  end
  
end
