# Scholarship Type Codes
class ScholarshipType < StudentInfo
  set_table_name "sys_tbl_45_scholarship"
  set_primary_key :table_key
  
  def description
    scholar_descrip.strip
  end
end
