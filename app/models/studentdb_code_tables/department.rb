# Department Codes
class Department < StudentInfo
  set_table_name "sr_dept_code"
  set_primary_key :dept_code
  
  has_many :majors, :class_name => "Major", :foreign_key => "major_dept"
  
  belongs_to :college, :class_name => "College", :foreign_key => [:dept_branch, :dept_college]
  belongs_to :department_extra, :class_name => "DepartmentExtra", :foreign_key => "dept_code", :primary_key => "dept_code"
  
  has_many :accountability_coordinator_authorizations, 
            :class_name => "UserUnitRoleAuthorization", 
            :as => :authorizable,
            :include => { :user_unit_role => :role },
            :conditions => { "roles.name" => "accountability_department_coordinator" }
  
  delegate :email, :fullname, :chair_name, :chair_title, :chair_email, :to => :department_extra
  
  # Alias for department_full_name().
  def name
    department_full_name
  end
  
  # Returns a stripped and titleized version of the department name
  def department_full_name
    return department_extra.fixed_name if department_extra && !department_extra.fixed_name.blank?
    dept_full_nm.strip.titleize.gsub("Of", "of")
  end
  
  # Returns a stripped version of the abbreviation
  def abbrev
    dept_abbr.strip
  end
  
end
