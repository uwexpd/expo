class CourseExtraEnrollee < ActiveRecord::Base
  belongs_to :course, :foreign_key => [:ts_year, :ts_quarter, :course_branch, :course_no, :dept_abbrev, :section_id]
  belongs_to :person
  
  validates_presence_of :person
  validates_associated :person
  
  
end
