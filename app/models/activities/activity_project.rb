# Models a individual student project that should be counted in an accountability report. See AccountabilityReport for more information.
class ActivityProject < Activity
  validates_presence_of :system_key
  
  belongs_to :student, :class_name => "StudentRecord", :foreign_key => "system_key"

  # Only return records with quarters that match the requested quarter
  named_scope :for_quarter, lambda { |q|
    { :select => "DISTINCT activities.*", 
      :joins => :quarters, 
      :conditions => "activity_quarters.quarter_id IN (#{q.is_a?(Array) ? q.collect(&:id).join(",") : q.id})" }
  }
  
  # Only return records assigned to this department
  named_scope :for_department, lambda { |d|
    if d.is_a?(DepartmentExtra)
      if !d.dept_code.blank?
        { :conditions => { :department_id => d.dept_code }}
      elsif d.fixed_name.blank?
        { :conditions => { :department_id => 99999999 }} # return nothing
      else
        { :conditions => { :department_name => d.fixed_name }}
      end
    elsif d.is_a?(Department)
      { :conditions => { :department_id => d.id }}
    elsif d.is_a?(String)
      { :conditions => { :department_name => d }}
    end
  }

  private

  def self.correct_dept_id(obj)
    obj.is_a?(DepartmentExtra) ? obj.dept_code : obj.id
  end
  
end