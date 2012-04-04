# Models a course that should be counted in an accountability report. See AccountabilityReport for more information.
# 
# * For ActivityCourse records, a separate "reporting department" can be specified. For example, a BIO course might be
#   reported by the Medical School, in which case, both Biology and the Medical School will receive "credit" when the
#   accountability report is run.
class ActivityCourse < Activity
  validates_presence_of :ts_year, :ts_quarter, :course_branch, :course_no, :dept_abbrev, :section_id
  validates_presence_of :course
  validates_associated :course
  validates_presence_of :activity_type_id
  
  belongs_to :course, :class_name => "Course", :foreign_key => [:ts_year, :ts_quarter, :course_branch, :course_no, :dept_abbrev, :section_id]
  belongs_to :reporting_department, :class_name => "Department", :foreign_key => "reporting_department_id"
  belongs_to :preparer, :class_name => "Unit", :foreign_key => "preparer_uw_netid", :primary_key => "login"
  
  delegate :registrants, :to => :course
  
  # Auto-sets the +ts_quarter+ and +ts_year+ attributes when the quarter_id is set.
  def quarter_id=(q_id)
    q = Quarter.find(q_id)
    write_attribute(:ts_year, q.year)
    write_attribute(:ts_quarter, q.quarter_code_id)
    write_attribute(:quarter_id, q.id)
  end
  
  # Returns the ActivityCourse records that fall in the given quarter (or quarters if an array is specified)
  def self.for_quarter(quarter)
    if quarter.is_a?(Array)
      quarter.collect{|q| ActivityCourse.for_quarter(q)}.flatten
    else
      find(:all, :conditions => { :quarter_id => quarter.id })
    end
  end
  
  # If this record has a reporting department, returns the name of that department.
  def full_reporting_department_name
    return nil if reporting_department_id.nil? && reporting_department_name.blank?
    return reporting_department.name if reporting_department
    reporting_department_name
  end
  
  # Returns the ActivityCourse records that fall in the given quarter (or quarters if an array is specified)
  # and belong to the specified department. This can be an actual Department, DepartmentExtra, or String of a department
  # name, and will return records that match on department_id OR reporting_department_id.
  def self.for_quarter_and_department(quarter, department)
    conditions = []
    quarter = [quarter] unless quarter.is_a?(Array)
    conditions << "(#{quarter.collect{|q| "quarter_id = #{q.id}"}.join(" OR ")})"

    if department.is_a?(Department)
      conditions << "(department_id = #{department.id} OR reporting_department_id = #{department.id})"
    elsif department.is_a?(DepartmentExtra)
      if department.dept_code
        conditions << "(department_id = #{department.dept_code} OR reporting_department_id = #{department.dept_code})"
      else
        conditions << "reporting_department_name = '#{department.fixed_name}'"
      end
    elsif department.is_a?(String)
      conditions << "reporting_department_name = '#{department}'"
    else
      raise "You must pass a Department, DepartmentExtra, or a String"
    end
    find(:all, :conditions => conditions.join(" AND "))
  end
  
  # Returns true if this ActivityCourse belongs to (should be credited to) the requested department.
  def belongs_to_department?(department)
    if department.is_a?(Department)
      department_id == department.id || reporting_department_id == department.id
    elsif department.is_a?(DepartmentExtra)
      if department.dept_code
        department_id == department.dept_code || reporting_department_id == department.dept_code
      else
        reporting_department_name == department.fixed_name
      end
    elsif department.is_a?(String)
      reporting_department_name == department
    else
      raise "You must pass a Department, DepartmentExtra, or a String"
    end
  end
  
  # Returns true if this ActivityCourse can be edited by the requested department. If the credited department is the same, then
  # this is true. If the reporting department is the same, then this is true. Otherwise, this is false.
  def can_be_edited_by?(department)
    if reporting_department_id.nil? && reporting_department_name.blank?
      belongs_to_department?(department) # no "reporting department" so just check if it belongs to the department or not
    else
      if department.is_a?(Department)
        reporting_department_id == department.id
      elsif department.is_a?(DepartmentExtra)
        if department.dept_code
          reporting_department_id == department.dept_code
        else
          reporting_department_name == department.fixed_name
        end
      elsif department.is_a?(String)
        reporting_department_name == department
      else
        raise "You must pass a Department, DepartmentExtra, or a String"
      end
    end
  end
  
  
end