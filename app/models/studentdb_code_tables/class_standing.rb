# Simple mapping of class_standing codes to full titles (e.g., Freshman, Sophomore, ...).
# - This table was created because it does not exist in the UWSDB.  The codes contained within is based off the code table at the Data Warehouse website and is assumed to be constant.
class ClassStanding < ActiveRecord::Base
  has_one :student_record, :class_name => "StudentRecord", :foreign_key => "class"
  
  named_scope :undergraduate, :conditions => ['id <= 7']
end
