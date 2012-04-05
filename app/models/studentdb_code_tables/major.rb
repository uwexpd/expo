# Major codes
class Major < StudentInfo
  set_table_name "sr_major_code"
  set_primary_keys :major_branch, :major_pathway, :major_last_yr, :major_last_qtr, :major_abbr
  # belongs_to :major_extra, :foreign_key => [:major_branch, :major_pathway, :major_last_yr, :major_last_qtr, :major_abbr]  
  belongs_to :department, :class_name => "Department", :foreign_key => "major_dept"
  
  def <=>(o)
    title <=> o.title rescue 0
  end
  
  # Association for MajorExtra
  # TODO restore this as a real association
  def major_extra
    MajorExtra.find_by_major_branch_and_major_pathway_and_major_last_yr_and_major_last_qtr_and_major_abbr(
      major_branch, major_pathway, major_last_yr, major_last_qtr, major_abbr
    )
  end
  
  # Alias for major_full_nm
  def title
    return major_extra.fixed_name if major_extra && !major_extra.fixed_name.blank?
    major_full_nm.strip
  end

  def discipline_category
    major_extra.nil? ? nil : major_extra.discipline_category
  end

  # Finds the most current major based on the abbreviation supplied. Note that this might return a non-current
  # major if there aren't any current majors matching your query.
  def self.find_by_abbrev(abbrev, qtr = Quarter.current_quarter)
    self.find :first, 
              :conditions => {:major_abbr => abbrev},
              :order => "major_last_yr DESC, major_last_qtr DESC"
  end
  
end
