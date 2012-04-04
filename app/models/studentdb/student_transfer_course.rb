class StudentTransferCourse < StudentInfo
  set_table_name "sr_transfer_crs"
  set_primary_keys :system_key, :institution_code
  belongs_to :transfer, :class_name => "StudentTransfer", :foreign_key => ["system_key", "institution_code"]
  
  # Returns the grade earned in the course, properly formatted. Since the SDB stores grades as strings with no decimals, two digit
  # grades must be converted into a decimal number, but strings such as "CR" for credit/no-credit classes must stay the same
  def grade_formatted
    grade = tfr_uw_grade
    return "X" if grade.strip.blank?
    return "0.0" if grade == "00"
    return (grade.to_f/10).to_s unless grade.to_f == 0.0
    return grade
  end
  
  
end