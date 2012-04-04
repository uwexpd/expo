# Stores some extra information about departments that isn't available in the SDB, such as chair name and emails, and department names that are suitable for printing.
class DepartmentExtra < ActiveRecord::Base
  belongs_to :department, :foreign_key => :dept_code

  has_many :accountability_coordinator_authorizations, 
            :class_name => "UserUnitRoleAuthorization", 
            :as => :authorizable,
            :include => { :user_unit_role => :role },
            :conditions => { "roles.name" => "accountability_department_coordinator" }
  
  PLACEHOLDER_CODES = %w( name chair_name chair_email chair_title )
  
  delegate :abbrev, :college, :to => :department
  
  def email
    chair_email
  end 
  
  def fullname
    chair_name
  end
  
  def name
    department.nil? ? fixed_name : (fixed_name.blank? ? department.name : fixed_name)
  end
  
end
