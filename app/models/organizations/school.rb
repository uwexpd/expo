class School < Organization
  belongs_to :school_type, :class_name => "SchoolType"
  
  validates_presence_of :school_type
  
  
end