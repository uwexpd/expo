# Special Program Codes (unknown?)
class SpecialProgram < StudentInfo
  set_table_name "sys_tbl_34_spcl_pgm"
  # set_primary_keys :table_type, :table_key
  set_primary_key :table_key
  
  PLACEHOLDER_CODES = %w(description)
  
  def description
    sp_pgm_descrip.strip
  end
end
