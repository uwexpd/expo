# College Codes
class College < StudentInfo
  set_table_name "sr_coll_code"
  set_primary_keys :college_branch, :college_code
  
  def name
    college_name.strip
  end

  def full_name
    college_full_nm.strip.titleize.gsub("Of", "of")
  end

  def campus_name
    case college_branch
    when 0
      "Seattle"
    when 1
      "Bothell"
    when 2
      "Tacoma"
    else
      "Error: college branch has an invalid value: #{college_branch}"
    end
  end
  
end
