class StudentCalendarQuarter < StudentInfo
  set_table_name "sys_tbl_39_calendar"
  set_primary_keys :table_key
  
  def quarter
    regexp = /\d(\d{4})(\d)/
    Quarter.find_easily(table_key[regexp,2], table_key[regexp,1])
  end
  
  def include?(date)
    date >= first_day && date < last_day_classes
  end
  
  # Returns the quarter where the specified date falls. Returns nil if classes aren't in session at that time.
  def self.find_by_date(qdate)
    self.find(:first, :conditions => [":qdate >= first_day AND :qdate < last_day_classes", {:qdate => qdate.to_s(:db)}])
  end
  
end