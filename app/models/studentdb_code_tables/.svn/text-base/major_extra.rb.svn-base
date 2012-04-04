# Since the SDB is dumb, we have to store some extra information about majors, such as a title that is suitable for printing! ARGH!
class MajorExtra < ActiveRecord::Base
  #set_primary_keys :major_branch, :major_pathway, :major_last_yr, :major_last_qtr, :major_abbr
  belongs_to :major, :foreign_key => [:major_branch, :major_pathway, :major_last_yr, :major_last_qtr, :major_abbr]
  belongs_to :discipline_category, :class_name => "DisciplineCategory", :foreign_key => "discipline_category_id"
  
  PLACEHOLDER_CODES = %w( fixed_name chair_name temp_num_students )

  # delegate :major_abbr, :to => :major  # BUG why is this here? We already know major_abbr here.
  
  def email
    chair_email
  end 
  
  def fullname
    chair_name
  end
  
  def <=>(o)
    major.title <=> o.major.title rescue 0
  end
  
  def major_id
    return self.major.nil? ? nil : self.major.id 
  end
  
  def major_id=(new_major_id)
	  self.major = Major.find new_major_id
  end
  
  def title
	  return major.title
  end
  
end
